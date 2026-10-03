#!/usr/bin/env bash
# Bootstrap this dotfiles repo on macOS, Ubuntu, or Arch.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_TARGET="${HOME}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
LOCAL_BIN="${HOME}/.local/bin"

DRY_RUN=0
SKIP_PACKAGES=0
STOW_ONLY=0
ADOPT=0
PACKAGES=(ghostty git tmux vim zsh)

usage() {
	cat <<'EOF'
Usage: ./setup.sh [options]

Idempotent bootstrap for macOS (Homebrew), Ubuntu/Debian (apt), and Arch (pacman).
Safe to re-run.

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

# Runs in a subshell via $(detect_os); sourcing os-release cannot leak.
detect_os() {
	case "$(uname -s)" in
	Darwin)
		printf 'macos'
		return
		;;
	Linux) ;;
	*)
		printf 'unknown'
		return
		;;
	esac

	if [[ ! -f /etc/os-release ]]; then
		printf 'unknown'
		return
	fi
	# shellcheck disable=SC1091
	. /etc/os-release
	local id="${ID:-}"
	local like=" ${ID_LIKE:-} "

	case "$id" in
	ubuntu | debian | pop | linuxmint | elementary | neon)
		printf 'ubuntu'
		return
		;;
	arch | artix | endeavouros | manjaro | cachyos | archlinux)
		printf 'arch'
		return
		;;
	esac

	case "$like" in
	*' debian '* | *' ubuntu '*)
		printf 'ubuntu'
		return
		;;
	*' arch '*)
		printf 'arch'
		return
		;;
	esac

	printf 'unknown'
}

have_cli_deps() {
	need_cmd stow &&
		need_cmd git &&
		need_cmd zsh &&
		need_cmd tmux &&
		need_cmd vim &&
		need_cmd fzf &&
		need_cmd starship &&
		{ need_cmd fd || need_cmd fdfind; }
}

root_cmd() {
	if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
		run "$@"
	elif need_cmd sudo; then
		run sudo "$@"
	else
		err "Installing packages needs root, and sudo is not available."
		printf '  Install stow zsh git tmux vim fzf fd starship, then: %s/setup.sh --skip-packages\n' "$REPO_ROOT" >&2
		exit 1
	fi
}

install_starship_upstream() {
	if need_cmd starship; then
		log "starship already on PATH"
		return 0
	fi
	run mkdir -p "$LOCAL_BIN"
	if ((DRY_RUN)); then
		log "[dry-run] curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b $LOCAL_BIN"
		return 0
	fi
	curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$LOCAL_BIN"
}

ensure_fd_name() {
	if need_cmd fd; then
		return 0
	fi
	if ! need_cmd fdfind; then
		return 0
	fi
	run mkdir -p "$LOCAL_BIN"
	if ((DRY_RUN)); then
		log "[dry-run] ln -sfn $(command -v fdfind) $LOCAL_BIN/fd"
		return 0
	fi
	ln -sfn "$(command -v fdfind)" "$LOCAL_BIN/fd"
	log "linked $LOCAL_BIN/fd -> $(command -v fdfind)"
}

optional_brew_cask() {
	local cask="$1"
	if ! brew info --cask "$cask" >/dev/null 2>&1; then
		log "optional cask not available, skipping: $cask"
		return 0
	fi
	if brew list --cask "$cask" >/dev/null 2>&1; then
		log "cask already installed: $cask"
		return 0
	fi
	run brew install --cask "$cask" || log "optional cask install failed, skipping: $cask"
}

install_packages_macos() {
	if ! need_cmd brew; then
		err "Homebrew is not installed (required on macOS)."
		printf '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"\n' >&2
		printf '  Then re-run: %s/setup.sh\n' "$REPO_ROOT" >&2
		exit 1
	fi
	local formulae="stow zsh git tmux vim fd fzf starship"
	local missing=""
	local pkg
	for pkg in $formulae; do
		if brew list --formula "$pkg" >/dev/null 2>&1; then
			log "package already installed: $pkg"
		else
			missing="${missing:+$missing }$pkg"
		fi
	done
	if [[ -n "$missing" ]]; then
		# shellcheck disable=SC2086
		run brew install $missing
	fi
	optional_brew_cask font-jetbrains-mono-nerd-font
	optional_brew_cask ghostty
}

install_packages_ubuntu() {
	if ! need_cmd apt-get; then
		err "Ubuntu/Debian detected but apt-get was not found."
		printf '  %s/setup.sh --skip-packages\n' "$REPO_ROOT" >&2
		exit 1
	fi
	root_cmd env DEBIAN_FRONTEND=noninteractive apt-get update
	root_cmd env DEBIAN_FRONTEND=noninteractive apt-get install -y \
		curl git stow unzip zsh fzf fd-find tmux vim
	if apt-cache show starship >/dev/null 2>&1; then
		root_cmd env DEBIAN_FRONTEND=noninteractive apt-get install -y starship
	fi
	install_starship_upstream
	ensure_fd_name
}

install_packages_arch() {
	if ! need_cmd pacman; then
		err "Arch detected but pacman was not found."
		printf '  %s/setup.sh --skip-packages\n' "$REPO_ROOT" >&2
		exit 1
	fi
	root_cmd pacman -Sy --needed --noconfirm \
		curl git stow unzip zsh fzf fd tmux vim starship
	if pacman -Si ghostty >/dev/null 2>&1; then
		root_cmd pacman -S --needed --noconfirm ghostty || log "optional package install failed, skipping: ghostty"
	fi
	ensure_fd_name
}

install_packages() {
	local os="$1"
	if have_cli_deps; then
		log "CLI deps already present; skipping package manager"
		ensure_fd_name
		return 0
	fi
	case "$os" in
	macos) install_packages_macos ;;
	ubuntu) install_packages_ubuntu ;;
	arch) install_packages_arch ;;
	*)
		err "Unsupported OS ($os). This script supports macOS, Ubuntu/Debian, and Arch."
		printf '  Install stow zsh git tmux vim fzf fd starship, then: %s/setup.sh --skip-packages\n' "$REPO_ROOT" >&2
		exit 1
		;;
	esac
	if ! ((DRY_RUN)) && ! have_cli_deps; then
		err "Packages installed, but a required command is still missing from PATH."
		printf '  Need: stow git zsh tmux vim fzf starship, and fd or fdfind\n' >&2
		printf '  Ensure %s is on PATH, then re-run: %s/setup.sh --skip-packages\n' "$LOCAL_BIN" "$REPO_ROOT" >&2
		exit 1
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
		"${XDG_CACHE_HOME:-$HOME/.cache}/zsh" \
		"$LOCAL_BIN"
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
	export PATH="$LOCAL_BIN:$PATH"

	local os
	os="$(detect_os)"
	log "repo: $REPO_ROOT"
	log "target: $HOME_TARGET"
	log "os: $os"

	if ! ((STOW_ONLY)); then
		ensure_dirs
		if ! ((SKIP_PACKAGES)); then
			install_packages "$os"
		else
			ensure_fd_name
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
