.PHONY: install uninstall stow submodules zsh-plugins tmux-plugins nvim-sync

install:
	./install.sh

uninstall:
	./uninstall.sh

stow:
	stow --restow */

submodules:
	git submodule update --init --recursive

zsh-plugins:
	@for pair in "zsh-users:zsh-autosuggestions" "zdharma-continuum:fast-syntax-highlighting" "Aloxaf:fzf-tab"; do \
		user=$${pair%%:*}; repo=$${pair##*:}; \
		dir="$$HOME/.config/zsh/plugins/$$repo"; \
		[ -d "$$dir/.git" ] || git clone --depth=1 "https://github.com/$$user/$$repo" "$$dir"; \
	done

tmux-plugins:
	~/.config/tmux/plugins/tpm/bin/install_plugins

nvim-sync:
	nvim --headless "+packsync!" +qa