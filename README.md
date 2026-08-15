# dotfiles

Personal configs managed with [GNU Stow](https://www.gnu.org/software/stow/).

The clone path defaults to `$HOME/dotfiles` and is exported as `XDG_DOTFILES_HOME` from `~/.zshenv`.

## Quick start

```bash
git clone --recurse-submodules git@github.com:benbrackenbury/dotfiles.git "${XDG_DOTFILES_HOME:-$HOME/dotfiles}"
cd "${XDG_DOTFILES_HOME:-$HOME/dotfiles}"
./install.sh
```

`install.sh` (or `make install`) installs packages, restows every package directory, initializes submodules, and installs zsh, tmux, and nvim plugins.

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
| `cursor/` | `~/.config/cursor/` |
| `codex/` | `~/.codex/` |
| `opencode/` | `~/.config/opencode/` |
| `agents/` | `~/.agents/` |
| `themekit/` | `~/.local/bin/themekit`, `~/.config/themekit/` |
| `stow/` | `~/.stow-global-ignore` |

## Local overrides

Machine-specific settings live outside the repo:

- `~/.zshenv.local`, `~/.zshrc.local`
- `~/.gitconfig.local` (name, email, platform-specific git settings)
- `~/.config/tmux/local.tmux.conf` (see `local.tmux.conf.example`)
- `~/.config/ghostty/local.ghostty`

## Makefile

| Target | What it does |
|--------|----------------|
| `make install` | Run `install.sh` |
| `make uninstall` | Run `uninstall.sh` |
| `make stow` | Restow all packages |
| `make submodules` | Init/update git submodules |
| `make zsh-plugins` | Clone missing zsh plugins |
| `make tmux-plugins` | Install TPM plugins |
| `make nvim-sync` | Headless `nvim +packsync!` |

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

Or the matching `make` targets above.

## Neovim

Neovim config is a submodule pointing to [benbrackenbury/Neovim](https://github.com/benbrackenbury/Neovim). Requires Neovim 0.12.0+.

## Agents

`~/.agents/AGENTS.md` is the global agent instructions file. Project-local `AGENTS.md` files always override it.

Grok, Codex, and OpenCode each get a tool-specific `AGENTS.md` that is a symlink back to `~/.agents/AGENTS.md`, so one edit applies everywhere.

`~/.agents/skills/` is a shared skills directory. Add a skill folder there and it is available to every tool that reads `~/.agents`.

## Linux

`install.sh` supports apt, dnf, and pacman. It installs core packages and starship, then runs the same stow/submodule/plugin steps as macOS.

For git credentials, use `cache` or your distro's helper instead of `osxkeychain` — see `git/.gitconfig.local.example`.

## Uninstall

```bash
./uninstall.sh
```

Removes stow symlinks only. Installed packages and local override files are left in place.

## ThemeKit

`themekit` switches macOS appearance, wallpaper (desktop, screensaver, and lock screen), Ghostty, Neovim, btop, fzf, tmux, git delta, lazygit, bat, and optionally Cursor/VS Code and Obsidian together. It does not change Light / Dark / Auto.

```bash
themekit              # fzf picker
themekit list
themekit current
themekit set poimandres
themekit apply        # re-apply the active theme
```

Themes live in `themekit/.config/themekit/themes/<name>/`. Each theme has `theme.toml` (including a `[colors]` palette) plus optional `ghostty`, `neovim.lua`, `btop.theme`, and one `wallpaper.{png,jpg,…}`. Palette-driven files are generated into `~/.local/state/themekit/` on apply. A hand-written `ghostty` or `btop.theme` is kept and layered on top. If a theme has no wallpaper file, the current desktop is left alone.

`themekit set` never writes `AppleInterfaceStyle` or `AppleInterfaceStyleSwitchesAutomatically`.

## Terminal notes

- Ghostty uses `tmux-256color` to match tmux and avoid truecolor/key mismatches.
- Ghostty colours come from ThemeKit (`~/.local/state/themekit/ghostty`). Override in `local.ghostty` if needed.
- fzf / lazygit / bat / delta / tmux colours also come from ThemeKit state files. New shells pick them up; run `themekit apply` after a pull.
- The tmux status bar runs `starship prompt` via `starship.sh`, using the same config as zsh (`~/.config/zsh/starship.toml`). Override in `local.tmux.conf` if you prefer the plain `user@host` style.

## Zsh notes

- Interactive shells attach to an existing tmux session, or create one if none exists.
- `cursor` and `c` are aliases for `cursor-agent`. `oc` is an alias for `opencode`.
- nvm is lazy-loaded on first `nvm`/`node`/`npm`/`npx` use, with `--no-use` so project `.nvmrc` files do not auto-switch versions.
- `compinit -C` in `.zshrc` skips the security audit for faster startup. Run `compaudit` manually if you suspect unsafe completion file permissions.
