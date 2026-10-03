# dotfiles

Personal configs with [GNU Stow](https://www.gnu.org/software/stow/). Clone to `$HOME/dotfiles`.

Agents skills moved to https://github.com/benbrackenbury/skills

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./setup.sh          # preview: ./setup.sh --dry-run
```

`setup.sh` works on **macOS** (Homebrew), **Ubuntu/Debian** (apt), and **Arch** (pacman). It installs CLI deps, stows `ghostty git tmux vim zsh`, and sets up Zap and tmux plugins. Re-running is safe. See `./setup.sh --help`.
