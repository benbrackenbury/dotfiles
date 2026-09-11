# dotfiles

Personal configs with [GNU Stow](https://www.gnu.org/software/stow/). Clone to `$HOME/dotfiles` (`XDG_DOTFILES_HOME` in `~/.zshenv`).

## Setup

```bash
git clone --recurse-submodules git@github.com:benbrackenbury/dotfiles.git "${XDG_DOTFILES_HOME:-$HOME/dotfiles}"
cd "${XDG_DOTFILES_HOME:-$HOME/dotfiles}"
./install.sh
cp git/.gitconfig.local.example ~/.gitconfig.local
```

```bash
./update.sh     # needs a clean tree: pull, restow, plugins
./uninstall.sh  # stow symlinks only
```

`make install`, `make update`, and `make uninstall` run the same scripts.

Each top-level directory is a stow package.

## Local files

Not in the repo:

- `~/.zshenv.local`, `~/.zshrc.local`
- `~/.gitconfig.local`
- `~/.config/tmux/local.tmux.conf`
- `~/.config/ghostty/local.ghostty`

## Notes

- Neovim is a submodule, [benbrackenbury/Neovim](https://github.com/benbrackenbury/Neovim), 0.12+.
- `~/.agents/AGENTS.md` is global. Grok, Codex, and OpenCode symlink to it. A project `AGENTS.md` wins. Skills live in `~/.agents/skills/`.
- Linux: apt, dnf, or pacman. Use `cache` for git credentials, not `osxkeychain`.
- Ghostty uses `tmux-256color` and follows the OS: Flexoki Light or Gruvbox Dark Hard. Tmux status bar uses the same starship config as zsh.
- Interactive zsh attaches to tmux. Node is on PATH before nvm finishes loading. No auto `.nvmrc`. `compinit -C` skips the security audit.
- `~/.gitmessage` is empty so the commit template starts on a blank line.
