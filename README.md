# Dotfiles

## Installation

> [!TIP]
> It is recommended that you fork this repo first

```bash
git clone https://github.com/benbrackenbury/new-dotfiles.git ~/dotfiles
```

### Create symlinks

> [!WARNING]  
> This will overwrite and remove any existing dotfiles, back them up first


```bash
~/dotfiles/bin/link
```

### Install packages

The following package managers are supported

- Homebrew on macOS
- apt for Ubuntu/Debian systems
- yay for Arch systems

Edit `packages/packages.txt` for CLI applications and `packages/casks.txt` for GUI apps on macOS.<br/>
Systems using apt or yay will attempt to install packages in `casks.txt` anyway.

```bash

~/dotfiles/bin/install-packages
```

## Eject
The command

```bash
~/dotfiles/bin/eject
```

will unlink the dotfiles in your home directory from this repo.

The symlinks are removed then the files are copied from the `~/dotfiles` folder to your home directory.

## Notes

> [!NOTE]
> This dotfiles system has been mostly tested and developed on macOS 26.0 on an Apple Silicon machine,

### Neovim

My Neovim config is built for Neovim 0.12, which is currently in development.

To use the latest nightly build:

```bash
bob install nightly
bob use nightly
```

### tmux

tmux plugins are managed via [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm),
which is pre-installed in this repo.

Once in tmux, press <kbd>ctrl</kbd><kbd>b</kbd> + <kbd>I</kbd> to install the plugins specified
in the tmux config
