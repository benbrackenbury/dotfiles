# dotfiles

Personal configs managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick start

```bash
git clone --recurse-submodules git@github.com:benbrackenbury/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Copy local overrides after install:

```bash
cp git/.gitconfig.local.example ~/.gitconfig.local
# edit ~/.gitconfig.local with your name and email
```

## Packages

| Stow dir | Symlinks |
|----------|----------|
| `zsh/` | `~/.zshenv`, `~/.config/zsh/` |
| `git/` | `~/.gitconfig`, `~/.gitmessage`, `~/.gitignore` |
| `tmux/` | `~/.config/tmux/` |
| `nvim/` | `~/.config/nvim/` (submodule) |
| `ghostty/` | `~/.config/ghostty/` |
| `grok/` | `~/.grok/` |
| `stow/` | `~/.stow-global-ignore` |

## Local overrides

Machine-specific settings live outside the repo:

- `~/.zshenv.local`, `~/.zshrc.local`
- `~/.gitconfig.local` (name, email, platform-specific git settings)
- `~/.config/tmux/local.tmux.conf` (see `local.tmux.conf.example`)
- `~/.config/ghostty/local.ghostty`

## Commit template

`~/.gitmessage` is intentionally empty. Git's commit template adds a leading blank line in the editor.

## Updating

```bash
# zsh plugins
zplugin-update

# tmux plugins
# prefix + I

# nvim packages
nvim +packsync

# submodules
git submodule update --remote --merge
```

## Neovim

Neovim config is a submodule pointing to [benbrackenbury/Neovim](https://github.com/benbrackenbury/Neovim). Requires Neovim 0.12.0+.

## Linux

`install.sh` supports apt, dnf, and pacman. It installs core packages and starship, then runs the same stow/submodule/plugin steps as macOS.

For git credentials, use `cache` or your distro's helper instead of `osxkeychain` — see `git/.gitconfig.local.example`.

## Uninstall

```bash
./uninstall.sh
```

Removes stow symlinks only. Installed packages and local override files are left in place.

## Terminal notes

- Ghostty uses `tmux-256color` to match tmux and avoid truecolor/key mismatches.
- The tmux status bar runs `starship prompt` via `starship.sh`, using the same config as zsh (`~/.config/zsh/starship.toml`). Override in `local.tmux.conf` if you prefer the plain `user@host` style.

## Zsh notes

`compinit -C` in `.zshrc` skips the security audit for faster startup. Run `compaudit` manually if you suspect unsafe completion file permissions.