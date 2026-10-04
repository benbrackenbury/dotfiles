# dotfiles

Personal configs with [GNU Stow](https://www.gnu.org/software/stow/). Clone to `$HOME/dotfiles` (`XDG_DOTFILES_HOME` in `~/.zshenv`).

## Setup

```bash
git clone git@github.com:benbrackenbury/dotfiles.git "${XDG_DOTFILES_HOME:-$HOME/dotfiles}"
cd "${XDG_DOTFILES_HOME:-$HOME/dotfiles}"
stow --no-folding --restow ghostty git tmux vim zsh
```

Coming from v2 (the old master layout):

```bash
./migrate-to-v3.sh
```

That removes leftover v2 home symlinks, restows the packages above, copies zsh history to `~/.local/state/zsh/history`, and installs [zap](https://github.com/zap-zsh/zap) plus [tpm](https://github.com/tmux-plugins/tpm).

On a fresh machine, install zap and tpm the same way migrate does, or wait for a bootstrap script.

Each top-level directory is a stow package.

## Local files

Not in the repo:

- `~/.zshenv.local`, `~/.zshrc.local`, `~/.aliases.local`
- `~/.config/git/.gitconfig.local`
- `~/.config/tmux/local.tmux.conf`
- `~/.config/ghostty/local.ghostty`

## Notes

- Agent skills live in https://github.com/benbrackenbury/skills
- Ghostty sets `TERM` to `tmux-256color`. Tmux status uses the same starship config as zsh (`~/.config/tmux/starship.sh`).
- Node is on PATH before nvm finishes loading. No auto `.nvmrc`. `compinit -C` skips the security audit.
- `~/.config/git/.gitmessage` is empty so the commit template starts on a blank line.
