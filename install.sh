#!/usr/bin/env bash

if [[ "$OSTYPE" == "darwin"* ]]; then
	echo "Installing Homebrew ..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	echo "Installing packages ..."
	brew install fd fzf go htop neovim nvm ripgrep starship xcodes  watch stow anomalyco/tap/opencode tmux
	brew install --cask font-jetbrains-mono-nerd-font ghostty devcleaner docker-desktop \
		firefox google-chrome logi-options+ mullvad-vpn tailscale  transmission \
		tunnelblick utm vlc bambu-studio balenaetcher

fi

echo "Creating symlinks ..."
stow --restow */
