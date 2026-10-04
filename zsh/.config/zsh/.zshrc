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

# Vi mode before plugins so they bind Tab on viins, not emacs
set -o vi

# Plugins
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zdharma-continuum/fast-syntax-highlighting"
plug "Aloxaf/fzf-tab"

# Keybinds
bindkey -M viins 'jk' vi-cmd-mode
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey ' ' magic-space

source "$ZDOTDIR/fzf.zsh"
# After fzf so it keeps Tab (fzf-completion otherwise steals it)
plug "sunlei/zsh-ssh"
source "$ZDOTDIR/nvm.zsh"
source "$ZDOTDIR/.aliases"

# Starship
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"
[ -f "$ZDOTDIR/starship.toml" ] && eval "$(starship init zsh)"

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
