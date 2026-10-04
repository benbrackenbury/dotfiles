#!/usr/bin/env bash
# Bootstrap a new Mac from this repo: Homebrew, stow, Dock, Finder, and a few defaults.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOME_TARGET="${HOME}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
PACKAGES=(ghostty git tmux vim zsh)

DRY_RUN=0
YES=0

usage() {
	cat <<'EOF'
Usage: ./scripts/mac-setup/setup.sh [--dry-run] [--yes]

Installs Homebrew packages from Brewfile, stows ghostty git tmux vim zsh,
installs zap and tpm, then applies Dock layout, Finder prefs, and a few
other defaults copied from the machine this repo is maintained on.

Run from a clone of this repo. Intended for macOS.

  --dry-run   Print actions only
  --yes       Do not prompt

Examples:
  ./scripts/mac-setup/setup.sh --dry-run
  ./scripts/mac-setup/setup.sh --yes
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

confirm() {
	((YES)) && return 0
	((DRY_RUN)) && return 0
	printf 'Set up this Mac from %s? [y/N] ' "$REPO_ROOT"
	local reply
	read -r reply
	[[ "$reply" == y || "$reply" == Y ]]
}

ensure_macos() {
	if [[ "$(uname -s)" != Darwin ]]; then
		err "This script is for macOS."
		exit 1
	fi
}

ensure_clt() {
	if xcode-select -p >/dev/null 2>&1; then
		log "Xcode tools present"
		return 0
	fi
	if ((DRY_RUN)); then
		log "[dry-run] xcode-select --install"
		return 0
	fi
	local label=""
	label="$(softwareupdate --list 2>/dev/null | awk -F': ' '/Label: Command Line Tools/{print $2}' | tail -1 || true)"
	if [[ -n "$label" ]]; then
		sudo softwareupdate --install "$label"
		return 0
	fi
	err "Install Xcode Command Line Tools, then re-run: xcode-select --install"
	xcode-select --install || true
	exit 1
}

ensure_rosetta() {
	[[ "$(uname -m)" == arm64 ]] || return 0
	if pgrep -q oahd 2>/dev/null; then
		log "Rosetta present"
		return 0
	fi
	run sudo softwareupdate --install-rosetta --agree-to-license
}

brew_prefix() {
	if [[ -x /opt/homebrew/bin/brew ]]; then
		printf '%s\n' /opt/homebrew
	elif [[ -x /usr/local/bin/brew ]]; then
		printf '%s\n' /usr/local
	fi
}

load_brew() {
	local prefix
	prefix="$(brew_prefix)"
	[[ -n "$prefix" ]] || return 1
	# shellcheck disable=SC1091
	eval "$("$prefix/bin/brew" shellenv)"
}

ensure_brew() {
	if load_brew; then
		log "Homebrew present"
		return 0
	fi
	if ((DRY_RUN)); then
		log "[dry-run] install Homebrew"
		return 0
	fi
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	load_brew
}

brew_bundle() {
	if ((DRY_RUN)); then
		log "[dry-run] brew bundle --file $SCRIPT_DIR/Brewfile"
		return 0
	fi
	if ! need_cmd brew; then
		err "brew is not on PATH"
		exit 1
	fi
	brew bundle --file "$SCRIPT_DIR/Brewfile"
}

stow_packages() {
	if ! need_cmd stow && ! ((DRY_RUN)); then
		err "stow is not installed."
		exit 1
	fi
	run mkdir -p \
		"${XDG_CONFIG_HOME}/git" \
		"${XDG_CONFIG_HOME}/vim" \
		"${HOME_TARGET}/.local/state/vim/undo" \
		"${HOME_TARGET}/.local/state/zsh" \
		"${XDG_CONFIG_HOME}/nvm"
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
		log "[dry-run] $dest/bin/install_plugins"
		return 0
	fi
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

link_nvm() {
	local nvm_sh=""
	if need_cmd brew; then
		nvm_sh="$(brew --prefix nvm 2>/dev/null || true)/nvm.sh"
	fi
	[[ -f "$nvm_sh" ]] || return 0
	local dest="${XDG_CONFIG_HOME}/nvm/nvm.sh"
	if [[ -e "$dest" || -L "$dest" ]]; then
		return 0
	fi
	run ln -s "$nvm_sh" "$dest"
}

defaults_write() {
	if ((DRY_RUN)); then
		log "[dry-run] defaults write $*"
		return 0
	fi
	defaults write "$@"
}

apply_defaults() {
	defaults_write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true
	defaults_write NSGlobalDomain AppleActionOnDoubleClick -string Fill
	defaults_write NSGlobalDomain com.apple.trackpad.forceClick -bool true

	defaults_write com.apple.AppleMultitouchTrackpad Clicking -bool true
	defaults_write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true

	defaults_write com.apple.desktopservices DSDontWriteNetworkStores -bool true
	defaults_write com.apple.desktopservices DSDontWriteUSBStores -bool true

	defaults_write com.apple.dock tilesize -int 30
	defaults_write com.apple.dock orientation -string bottom
	defaults_write com.apple.dock autohide -bool false
	defaults_write com.apple.dock autohide-delay -float 0
	defaults_write com.apple.dock autohide-time-modifier -float 0.5
	defaults_write com.apple.dock magnification -bool false
	defaults_write com.apple.dock show-recents -bool true
	defaults_write com.apple.dock "wvous-br-corner" -int 1

	defaults_write com.apple.finder ShowPathbar -bool true
	defaults_write com.apple.finder ShowSidebar -bool true
	defaults_write com.apple.finder ShowHardDrivesOnDesktop -bool false
	defaults_write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
	defaults_write com.apple.finder ShowRemovableMediaOnDesktop -bool true
	defaults_write com.apple.finder ShowMountedServersOnDesktop -bool false
	defaults_write com.apple.finder FXPreferredViewStyle -string Nlsv
	defaults_write com.apple.finder FXDefaultSearchScope -string SCcf
	defaults_write com.apple.finder NewWindowTarget -string PfHm
	defaults_write com.apple.finder NewWindowTargetPath -string "file://${HOME_TARGET}/"
	defaults_write com.apple.finder _FXSortFoldersFirst -bool true

	defaults_write com.apple.screensaver showClock -bool true
}

# Resolve an .app by name. Skip tiles whose app is not installed yet.
app_path() {
	local name="$1" p
	for p in \
		"/System/Volumes/Preboot/Cryptexes/App/System/Applications/${name}" \
		"/System/Cryptexes/App/System/Applications/${name}" \
		"/System/Applications/${name}" \
		"/Applications/${name}" \
		"${HOME_TARGET}/Applications/${name}"; do
		if [[ -d "$p" ]]; then
			printf '%s\n' "$p"
			return 0
		fi
	done
	return 1
}

dock_add_app() {
	local path="$1"
	local url
	url="$(python3 -c 'import pathlib,sys; print(pathlib.Path(sys.argv[1]).resolve().as_uri())' "$path")"
	if ((DRY_RUN)); then
		log "[dry-run] dock add $path"
		return 0
	fi
	defaults write com.apple.dock persistent-apps -array-add "$(
		cat <<EOF
<dict>
	<key>tile-data</key>
	<dict>
		<key>file-data</key>
		<dict>
			<key>_CFURLString</key>
			<string>${url}</string>
			<key>_CFURLStringType</key>
			<integer>15</integer>
		</dict>
	</dict>
	<key>tile-type</key>
	<string>file-tile</string>
</dict>
EOF
	)"
}

dock_add_folder() {
	local path="$1"
	local url
	url="$(python3 -c 'import pathlib,sys; print(pathlib.Path(sys.argv[1]).resolve().as_uri().rstrip("/") + "/")' "$path")"
	if ((DRY_RUN)); then
		log "[dry-run] dock folder $path"
		return 0
	fi
	defaults write com.apple.dock persistent-others -array-add "$(
		cat <<EOF
<dict>
	<key>tile-data</key>
	<dict>
		<key>arrangement</key>
		<integer>1</integer>
		<key>displayas</key>
		<integer>0</integer>
		<key>file-data</key>
		<dict>
			<key>_CFURLString</key>
			<string>${url}</string>
			<key>_CFURLStringType</key>
			<integer>15</integer>
		</dict>
		<key>showas</key>
		<integer>1</integer>
	</dict>
	<key>tile-type</key>
	<string>directory-tile</string>
</dict>
EOF
	)"
}

apply_dock() {
	local apps=(
		Safari.app
		Messages.app
		Mail.app
		Cursor.app
		Maps.app
		Photos.app
		Phone.app
		FaceTime.app
		Calendar.app
		Reminders.app
		Notes.app
		Ghostty.app
		Xcode.app
		Figma.app
		BambuStudio.app
		TV.app
		Music.app
		Podcasts.app
		"Keynote Creator Studio.app"
		"Pages Creator Studio.app"
		"Numbers Creator Studio.app"
		"App Store.app"
		"iPhone Mirroring.app"
		"Siri AI.app"
		"System Settings.app"
	)
	local name path
	if ((DRY_RUN)); then
		log "[dry-run] replace Dock apps"
	else
		defaults write com.apple.dock persistent-apps -array
		defaults write com.apple.dock persistent-others -array
	fi
	fusion_path() {
		local found
		found="$(find "${HOME_TARGET}/Library/Application Support/Autodesk/webdeploy/production" -maxdepth 2 -name "Autodesk Fusion.app" 2>/dev/null | head -1 || true)"
		if [[ -n "$found" ]]; then
			printf '%s\n' "$found"
			return 0
		fi
		app_path "Autodesk Fusion.app"
	}

	for name in "${apps[@]}"; do
		if path="$(app_path "$name")"; then
			dock_add_app "$path"
		else
			log "skip dock tile (not installed): $name"
		fi
		if [[ "$name" == Figma.app ]]; then
			if path="$(fusion_path)"; then
				dock_add_app "$path"
			else
				log "skip dock tile (not installed): Autodesk Fusion.app"
			fi
		fi
	done
	dock_add_folder "${HOME_TARGET}/Downloads"
}

restart_ui() {
	if ((DRY_RUN)); then
		log "[dry-run] killall Dock Finder"
		return 0
	fi
	killall Dock Finder 2>/dev/null || true
}

main() {
	parse_args "$@"
	ensure_macos
	cd "$REPO_ROOT"

	if ! need_cmd git; then
		err "git is required"
		exit 1
	fi
	if ! need_cmd python3; then
		err "python3 is required"
		exit 1
	fi

	log "repo: $REPO_ROOT"
	log "target: $HOME_TARGET"

	if ! confirm; then
		log "aborted"
		exit 1
	fi

	ensure_clt
	ensure_rosetta
	ensure_brew
	brew_bundle
	stow_packages
	install_zap
	install_tpm
	install_tmux_starship_helper
	link_nvm
	apply_defaults
	apply_dock
	restart_ui

	if [[ ! -e "${XDG_CONFIG_HOME}/git/.gitconfig.local" ]]; then
		log "add ${XDG_CONFIG_HOME}/git/.gitconfig.local for user.name / user.email"
	fi
	log "done"
	log "open a new shell so ZDOTDIR and brew reload"
}

main "$@"
