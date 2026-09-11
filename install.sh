#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ "${OSTYPE:-}" == darwin* ]]; then
	echo "Installing Homebrew ..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	echo "Installing packages ..."
	brew install fd fzf go htop nvm ripgrep starship xcodes watch stow anomalyco/tap/opencode tmux gh
	brew install --cask font-jetbrains-mono-nerd-font ghostty devcleaner docker-desktop \
		google-chrome logi-options+ tailscale transmission \
		tunnelblick utm vlc bambu-studio balenaetcher autodesk-fusion figma \
		appcleaner 

elif [[ "${OSTYPE:-}" == linux-gnu* ]]; then
	echo "Installing packages ..."
	if command -v apt-get >/dev/null 2>&1; then
		sudo apt-get update
		sudo apt-get install -y curl git stow unzip zsh fzf fd-find tmux ripgrep
	elif command -v dnf >/dev/null 2>&1; then
		sudo dnf install -y curl git stow unzip zsh fzf fd-find tmux ripgrep
	elif command -v pacman >/dev/null 2>&1; then
		sudo pacman -S --needed curl git stow unzip zsh fzf fd tmux ripgrep
	else
		echo "Unsupported Linux distro — install stow, unzip, zsh, fzf, fd, tmux, and ripgrep manually."
	fi

	if ! command -v starship >/dev/null 2>&1; then
		curl -fsSL https://starship.rs/install.sh | sh -s -- -y
	fi
fi

echo "Installing neovim via bob ..."
export PATH="${HOME}/.local/bin:${PATH}"
export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/bob/nvim-bin:${PATH}"
if ! command -v bob >/dev/null 2>&1; then
	curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh | bash
fi
bob use stable

echo "Creating symlinks ..."
packages=(*/)
stow --restow --adopt "${packages[@]%/}"

echo "Initializing submodules ..."
git submodule update --init --recursive

install_zsh_plugin() {
	local user="$1" repo="$2"
	local dir="${HOME}/.config/zsh/plugins/${repo}"
	if [[ ! -d "${dir}/.git" ]]; then
		mkdir -p "${HOME}/.config/zsh/plugins"
		echo "Installing ${repo}..."
		git clone --depth=1 "https://github.com/${user}/${repo}" "${dir}"
	fi
}

echo "Installing zsh plugins ..."
install_zsh_plugin zsh-users zsh-autosuggestions
install_zsh_plugin zdharma-continuum fast-syntax-highlighting
install_zsh_plugin Aloxaf fzf-tab

echo "Installing tmux plugins ..."
if [[ -x "${HOME}/.config/tmux/plugins/tpm/bin/install_plugins" ]]; then
	"${HOME}/.config/tmux/plugins/tpm/bin/install_plugins"
fi

echo "Creating XDG directories ..."
mkdir -p "${HOME}/.local/state/zsh" "${HOME}/.cache/zsh" "${HOME}/.local/state/nvim/undo"

if command -v nvim >/dev/null 2>&1; then
	echo "Syncing nvim packages ..."
	nvim --headless "+packupdate!" +qa
fi

echo "Done."
