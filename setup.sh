#!/usr/bin/env bash
# Bootstrap this dotfiles repo: packages, GNU Stow, Zap, TPM, and local dirs.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_TARGET="${HOME}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

DRY_RUN=0
SKIP_PACKAGES=0
STOW_ONLY=0
ADOPT=0
PACKAGES=(ghostty git tmux vim zsh)

usage() {
	cat <<'EOF'
Usage: ./setup.sh [options]

Idempotent bootstrap for these stow packages. Safe to re-run.

Options:
  --dry-run         Print actions without changing the system
  --skip-packages   Do not install OS packages (stow/zsh/tmux/…)
  --stow-only       Only run stow (implies --skip-packages)
  --adopt           Pass --adopt to stow (take over existing files)
  --home DIR        Stow target (default: $HOME)
  -h, --help        Show this help

Examples:
  ./setup.sh
  ./setup.sh --dry-run
  ./setup.sh --stow-only
  ./setup.sh --skip-packages --home "$HOME"
EOF
}

log() { printf '%s\n' "$*"; }
err() { printf 'Error: %s\n' "$*" >&2; }
run() {
	if ((DRY_RUN)); then
		printf '[dry-run] %s\n' "$*"
		return 0
	fi
	"$@"
}

need_cmd() {
	command -v "$1" >/dev/null 2>&1
}

detect_os() {
	case "${OSTYPE:-$(uname -s)}" in
	darwin* | Darwin) printf 'darwin' ;;
	linux-gnu* | Linux) printf 'linux' ;;
	*) printf 'unknown' ;;
	esac
}

install_packages_darwin() {
	if ! need_cmd brew; then
		err "Homebrew is not installed."
		printf '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"\n' >&2
		printf '  Then re-run: %s/setup.sh\n' "$REPO_ROOT" >&2
		exit 1
	fi
	local formulae=(stow zsh git tmux vim fd fzf starship)
	local missing=()
	local pkg
	for pkg in "${formulae[@]}"; do
		if brew list --formula "$pkg" >/dev/null 2>&1; then
			log "package already installed: $pkg"
		else
			missing+=("$pkg")
		fi
	done
	if ((${#missing[@]})); then
		run brew install "${missing[@]}"
	fi
	if need_cmd brew && brew info --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1; then
		if brew list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1; then
			log "cask already installed: font-jetbrains-mono-nerd-font"
		else
			run brew install --cask font-jetbrains-mono-nerd-font
		fi
	fi
	if need_cmd brew && brew info --cask ghostty >/dev/null 2>&1; then
		if brew list --cask ghostty >/dev/null 2>&1; then
			log "cask already installed: ghostty"
		else
			run brew install --cask ghostty
		fi
	fi
}

install_packages_linux() {
	if need_cmd apt-get; then
		run sudo apt-get update
		run sudo apt-get install -y curl git stow unzip zsh fzf fd-find tmux vim
	elif need_cmd dnf; then
		run sudo dnf install -y curl git stow unzip zsh fzf fd-find tmux vim
	elif need_cmd pacman; then
		run sudo pacman -S --needed --noconfirm curl git stow unzip zsh fzf fd tmux vim
	else
		err "Unsupported Linux distro — install stow, zsh, git, tmux, vim, fzf, and fd, then re-run:"
		printf '  %s/setup.sh --skip-packages\n' "$REPO_ROOT" >&2
		exit 1
	fi
	if ! need_cmd starship; then
		if ((DRY_RUN)); then
			log "[dry-run] curl -fsSL https://starship.rs/install.sh | sh -s -- -y"
		else
			curl -fsSL https://starship.rs/install.sh | sh -s -- -y
		fi
	else
		log "starship already on PATH"
	fi
}

stow_packages() {
	if ! need_cmd stow && ! ((DRY_RUN)); then
		err "stow is not installed."
		printf '  %s/setup.sh\n' "$REPO_ROOT" >&2
		exit 1
	fi
	local stow_args=(--no-folding --restow --dir "$REPO_ROOT" --target "$HOME_TARGET")
	if ((ADOPT)); then
		stow_args+=(--adopt)
	fi
	local pkg
	for pkg in "${PACKAGES[@]}"; do
		if [[ ! -d "$REPO_ROOT/$pkg" ]]; then
			err "missing package directory: $REPO_ROOT/$pkg"
			exit 1
		fi
	done
	run stow "${stow_args[@]}" "${PACKAGES[@]}"
}

install_zap() {
	local dest="${XDG_DATA_HOME}/zap"
	if [[ -f "$dest/zap.zsh" ]]; then
		log "zap already installed: $dest"
		return 0
	fi
	run mkdir -p "$(dirname "$dest")"
	run git clone --depth=1 https://github.com/zap-zsh/zap.git "$dest"
}

install_tpm() {
	local dest="${XDG_CONFIG_HOME}/tmux/plugins/tpm"
	if [[ -x "$dest/tpm" || -f "$dest/tpm" ]]; then
		log "tpm already installed: $dest"
	else
		run mkdir -p "$(dirname "$dest")"
		run git clone --depth=1 https://github.com/tmux-plugins/tpm.git "$dest"
	fi
	if [[ -x "$dest/bin/install_plugins" ]]; then
		run "$dest/bin/install_plugins"
	elif ((DRY_RUN)); then
		log "[dry-run] $dest/bin/install_plugins"
	fi
}

install_tmux_starship_helper() {
	local dest="${XDG_CONFIG_HOME}/tmux/starship.sh"
	if [[ -e "$dest" ]]; then
		log "tmux starship helper already present: $dest"
		return 0
	fi
	if ((DRY_RUN)); then
		log "[dry-run] write $dest"
		return 0
	fi
	mkdir -p "$(dirname "$dest")"
	cat >"$dest" <<'EOF'
#!/usr/bin/env bash
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/zsh/starship.toml}"
export STARSHIP_SHELL=
exec starship prompt
EOF
	chmod +x "$dest"
	log "wrote $dest"
}

ensure_dirs() {
	run mkdir -p \
		"$XDG_CONFIG_HOME" \
		"$XDG_DATA_HOME" \
		"$XDG_STATE_HOME/vim/undo" \
		"$XDG_STATE_HOME/zsh" \
		"${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
}

parse_args() {
	while (($#)); do
		case "$1" in
		-h | --help)
			usage
			exit 0
			;;
		--dry-run) DRY_RUN=1 ;;
		--skip-packages) SKIP_PACKAGES=1 ;;
		--stow-only)
			STOW_ONLY=1
			SKIP_PACKAGES=1
			;;
		--adopt) ADOPT=1 ;;
		--home)
			if (($# < 2)); then
				err "No home directory specified."
				printf '  %s/setup.sh --home "$HOME"\n' "$REPO_ROOT" >&2
				exit 1
			fi
			HOME_TARGET="$2"
			shift
			;;
		--home=*)
			HOME_TARGET="${1#--home=}"
			;;
		*)
			err "Unknown option: $1"
			printf '  %s/setup.sh --help\n' "$REPO_ROOT" >&2
			exit 1
			;;
		esac
		shift
	done
}

main() {
	parse_args "$@"
	cd "$REPO_ROOT"

	local os
	os="$(detect_os)"
	log "repo: $REPO_ROOT"
	log "target: $HOME_TARGET"
	log "os: $os"

	if ! ((STOW_ONLY)); then
		ensure_dirs
		if ! ((SKIP_PACKAGES)); then
			case "$os" in
			darwin) install_packages_darwin ;;
			linux) install_packages_linux ;;
			*)
				err "Unsupported OS ($os). Install stow/zsh/git/tmux/vim/fzf/fd/starship, then:"
				printf '  %s/setup.sh --skip-packages\n' "$REPO_ROOT" >&2
				exit 1
				;;
			esac
		fi
	fi

	stow_packages

	if ! ((STOW_ONLY)); then
		install_zap
		install_tpm
		install_tmux_starship_helper
	fi

	log "bootstrap complete"
	log "stow: ${PACKAGES[*]} -> $HOME_TARGET"
	if ((DRY_RUN)); then
		log "mode: dry-run (no changes)"
	fi
}

main "$@"
