#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ -n "$(git status --porcelain)" ]]; then
	echo "Working tree is not clean. Aborting."
	git status
	exit 1
fi

echo "Pulling ..."
git pull --ff-only

echo "Updating submodules ..."
git submodule update --init --recursive

echo "Restowing ..."
stow --restow */

echo "Updating zsh plugins ..."
for dir in "${HOME}/.config/zsh/plugins"/*/; do
	if [[ -d "${dir}/.git" ]]; then
		echo "Updating $(basename "$dir")..."
		git -C "$dir" pull --ff-only
	fi
done

echo "Updating tmux plugins ..."
if [[ -x "${HOME}/.config/tmux/plugins/tpm/bin/install_plugins" ]]; then
	"${HOME}/.config/tmux/plugins/tpm/bin/install_plugins"
fi
if [[ -x "${HOME}/.config/tmux/plugins/tpm/bin/update_plugins" ]]; then
	"${HOME}/.config/tmux/plugins/tpm/bin/update_plugins" all
fi

if command -v nvim >/dev/null 2>&1; then
	echo "Syncing nvim packages ..."
	nvim --headless "+packsync!" +qa
fi

echo "Done."
