[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

if [[ -z "$XDG_CONFIG_HOME" ]]
then
	export XDG_CONFIG_HOME="$HOME/.config"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
then
	export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi

if [[ -z "$XDG_DOTFILES_HOME" ]]
then
	export XDG_DOTFILES_HOME="$HOME/dotfiles"
fi
