#!/usr/bin/env bash
# Move a machine that was stowed from master/v2 onto this v3 tree.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_TARGET="${HOME}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
PACKAGES=(ghostty git tmux vim zsh)

DRY_RUN=0
YES=0

usage() {
	cat <<'EOF'
Usage: ./migrate-to-v3.sh [--dry-run] [--yes]

Removes home-directory symlinks that still point at this repo's v2 layout,
moves ~/.gitconfig.local to ~/.config/git/.gitconfig.local,
then stows ghostty git tmux vim zsh.

Zsh history is copied out first and written back to ~/.local/state/zsh/history
as a real file (same place v3 and vim state live).

  --dry-run   Print actions only
  --yes       Do not prompt
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

parse_args() {
	while (($#)); do
		case "$1" in
		-h | --help)
			usage
			exit 0
			;;
		--dry-run) DRY_RUN=1 ;;
		--yes) YES=1 ;;
		*)
			err "Unknown option: $1"
			usage >&2
			exit 1
			;;
		esac
		shift
	done
}

# Print dest of a symlink without requiring the dest to exist.
link_dest() {
	python3 - "$1" <<'PY'
import os, sys
path = sys.argv[1]
raw = os.readlink(path)
print(os.path.normpath(raw if os.path.isabs(raw) else os.path.join(os.path.dirname(path), raw)))
PY
}

is_repo_link() {
	local path="$1" dest
	[[ -L "$path" ]] || return 1
	dest="$(link_dest "$path")"
	[[ "$dest" == "$REPO_ROOT" || "$dest" == "$REPO_ROOT"/* ]]
}

scan_repo_links() {
	python3 - "$REPO_ROOT" "$HOME_TARGET" "$XDG_CONFIG_HOME" <<'PY'
import os, sys
repo = os.path.realpath(sys.argv[1])
home = sys.argv[2]
xdg = sys.argv[3]
v2_packages = {
    "agents", "cursor", "ghostty", "git", "grok", "herdr", "nvim", "stow", "tmux", "zsh",
}
roots = [
    (home, 1),
    (xdg, 4),
    (os.path.join(home, ".local"), 3),
    (os.path.join(home, ".cursor"), 3),
    (os.path.join(home, ".agents"), 2),
    (os.path.join(home, ".grok"), 2),
]
seen = set()

def dest_of(path):
    raw = os.readlink(path)
    if not os.path.isabs(raw):
        raw = os.path.join(os.path.dirname(path), raw)
    return os.path.normpath(raw)

def is_v2_link(dest):
    if dest == repo or not dest.startswith(repo + os.sep):
        return False
    pkg = os.path.relpath(dest, repo).split(os.sep, 1)[0]
    return pkg in v2_packages

for root, depth in roots:
    if not os.path.isdir(root):
        continue
    for dirpath, dirnames, filenames in os.walk(root, followlinks=False):
        rel = os.path.relpath(dirpath, root)
        parts = [] if rel == os.curdir else rel.split(os.sep)
        if len(parts) >= depth:
            dirnames[:] = []
        for name in dirnames + filenames:
            path = os.path.join(dirpath, name)
            if not os.path.islink(path) or path in seen:
                continue
            try:
                dest = dest_of(path)
            except OSError:
                continue
            if is_v2_link(dest):
                seen.add(path)
                print(path)
PY
}

remove_link() {
	local path="$1"
	if ((DRY_RUN)); then
		log "[dry-run] rm $path"
		return 0
	fi
	rm "$path"
	log "removed $path"
}

move_git_local() {
	local src="${HOME_TARGET}/.gitconfig.local"
	local dest="${XDG_CONFIG_HOME}/git/.gitconfig.local"
	if [[ ! -e "$src" && ! -L "$src" ]]; then
		log "no ~/.gitconfig.local to move"
		return 0
	fi
	if [[ -e "$dest" || -L "$dest" ]]; then
		log "keeping $dest (already exists); left $src in place"
		return 0
	fi
	run mkdir -p "$(dirname "$dest")"
	run mv "$src" "$dest"
	((DRY_RUN)) || log "moved $src -> $dest"
}

stow_v3() {
	if ! need_cmd stow && ! ((DRY_RUN)); then
		err "stow is not installed."
		exit 1
	fi
	run stow --no-folding --restow --dir "$REPO_ROOT" --target "$HOME_TARGET" "${PACKAGES[@]}"
}

install_zap() {
	local dest="${XDG_DATA_HOME}/zap"
	if [[ -f "$dest/zap.zsh" ]]; then
		log "zap already installed"
		return 0
	fi
	run mkdir -p "$(dirname "$dest")"
	run git clone --depth=1 https://github.com/zap-zsh/zap.git "$dest"
}

install_tpm() {
	local dest="${XDG_CONFIG_HOME}/tmux/plugins/tpm"
	local conf="${XDG_CONFIG_HOME}/tmux/tmux.conf"
	local plugin_path="${XDG_CONFIG_HOME}/tmux/plugins/"
	if [[ -x "$dest/tpm" || -f "$dest/tpm" ]]; then
		log "tpm already installed"
	else
		run mkdir -p "$(dirname "$dest")"
		run git clone --depth=1 https://github.com/tmux-plugins/tpm.git "$dest"
	fi
	if ! [[ -x "$dest/bin/install_plugins" ]]; then
		return 0
	fi
	if ((DRY_RUN)); then
		log "[dry-run] tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH $plugin_path"
		log "[dry-run] $dest/bin/install_plugins"
		return 0
	fi
	# Existing tmux servers keep old env; tpm's CLI reads that, not tmux.conf.
	tmux start-server
	tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$plugin_path" || true
	tmux source-file "$conf" || true
	"$dest/bin/install_plugins" || log "tpm plugins will install the next time tmux starts"
}

install_tmux_starship_helper() {
	local dest="${XDG_CONFIG_HOME}/tmux/starship.sh"
	if [[ -e "$dest" ]]; then
		log "tmux starship helper already present"
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
		"${XDG_CONFIG_HOME}/git" \
		"${XDG_CONFIG_HOME}/vim" \
		"${HOME_TARGET}/.local/state/vim/undo" \
		"${HOME_TARGET}/.local/state/zsh"
}

history_candidates() {
	printf '%s\n' \
		"$XDG_STATE_HOME/zsh/history" \
		"$XDG_STATE_HOME/zsh/.zsh_history" \
		"${XDG_CONFIG_HOME}/zsh/.zsh_history" \
		"${REPO_ROOT}/zsh/.config/zsh/.zsh_history" \
		"${HOME_TARGET}/.zsh_history"
}

HISTORY_BACKUP=""
HISTORY_RESTORE=""

backup_zsh_history() {
	local dest="$XDG_STATE_HOME/zsh/migrate-v3-history"
	HISTORY_BACKUP="$dest"
	if ((DRY_RUN)); then
		log "[dry-run] mkdir -p $dest"
	else
		mkdir -p "$dest"
	fi

	local src base i=0 saved="" size best=0
	while IFS= read -r src; do
		[[ -f "$src" && -s "$src" ]] || continue
		base="$(basename "$src")"
		i=$((i + 1))
		saved="$dest/$i-$base"
		if ((DRY_RUN)); then
			log "[dry-run] cp -p $src $saved"
		else
			cp -p "$src" "$saved"
		fi
		log "history backup: $src -> $saved"
		size=$(wc -c <"$src")
		if ((size > best)); then
			best=$size
			# Restore from the backup copy so it still exists after ~/.config/zsh is unlinked.
			if ((DRY_RUN)); then
				HISTORY_RESTORE="$src"
			else
				HISTORY_RESTORE="$saved"
			fi
		fi
	done < <(history_candidates)

	if [[ -z "$HISTORY_RESTORE" ]]; then
		log "no zsh history files found"
		return 0
	fi
	log "will restore $best bytes from $HISTORY_RESTORE"
}

restore_zsh_history() {
	local dest="$XDG_STATE_HOME/zsh/history"
	if [[ -z "$HISTORY_RESTORE" ]]; then
		return 0
	fi

	run mkdir -p "$(dirname "$dest")"
	if [[ -L "$dest" ]]; then
		run rm "$dest"
	fi

	if [[ -e "$dest" && "$HISTORY_RESTORE" -ef "$dest" ]]; then
		log "zsh history already at $dest"
		return 0
	fi

	if ((DRY_RUN)); then
		log "[dry-run] cp -p $HISTORY_RESTORE $dest"
		return 0
	fi
	cp -p "$HISTORY_RESTORE" "$dest"
	chmod 600 "$dest"
	log "restored zsh history -> $dest"
}

confirm() {
	((YES)) && return 0
	((DRY_RUN)) && return 0
	printf 'Migrate %s from v2 symlinks to v3? [y/N] ' "$HOME_TARGET"
	local reply
	read -r reply
	[[ "$reply" == y || "$reply" == Y ]]
}

main() {
	parse_args "$@"
	cd "$REPO_ROOT"

	if ! need_cmd git; then
		err "git is required"
		exit 1
	fi

	log "repo: $REPO_ROOT"
	log "target: $HOME_TARGET"

	local links=()
	local line
	while IFS= read -r line; do
		[[ -n "$line" ]] && links+=("$line")
	done < <(scan_repo_links)

	if ((${#links[@]})); then
		log "repo symlinks to remove:"
		printf '  %s\n' "${links[@]}"
	else
		log "no repo-owned home symlinks found"
	fi

	backup_zsh_history

	if ! confirm; then
		log "aborted"
		exit 1
	fi

	local path
	for path in "${links[@]}"; do
		remove_link "$path"
	done

	move_git_local
	ensure_dirs
	stow_v3
	restore_zsh_history
	install_zap
	install_tpm
	install_tmux_starship_helper

	log "done"
	log "open a new shell so ZDOTDIR and git config reload"
}

main "$@"
