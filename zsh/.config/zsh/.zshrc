export EDITOR=vi
export VISUAL="$EDITOR"

export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# History + options
: "${XDG_STATE_HOME:=$HOME/.local/state}"
mkdir -p "$XDG_STATE_HOME/zsh"
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS
setopt NOBEEP NUMERIC_GLOB_SORT

# Completions
autoload -Uz compinit
compinit -C -d "$XDG_STATE_HOME/zsh/zcompdump"

# Plugins
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zdharma-continuum/fast-syntax-highlighting"
plug "Aloxaf/fzf-tab"

# Keybinds
set -o vi
bindkey -M viins 'jk' vi-cmd-mode
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey ' ' magic-space

source "$ZDOTDIR/fzf.zsh"
source "$ZDOTDIR/nvm.zsh"
source "$ZDOTDIR/.aliases"

# Starship
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"
[ -f "$ZDOTDIR/starship.toml" ] && eval "$(starship init zsh)"

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
