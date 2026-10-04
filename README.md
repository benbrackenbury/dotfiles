# dotfiles

Personal configs with [GNU Stow](https://www.gnu.org/software/stow/). Clone to `$HOME/dotfiles`.

New Mac:

```sh
git clone git@github.com:benbrackenbury/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/mac-setup/setup.sh --yes
```

`./scripts/mac-setup/setup.sh --dry-run` prints the plan. `./migrate-to-v3.sh` is only for machines still on the v2 layout.

Add `~/.config/git/.gitconfig.local` for `user.name` and `user.email`.

Agents skills moved to https://github.com/benbrackenbury/skills
