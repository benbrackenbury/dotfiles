source "$ZDOTDIR/environment.zsh"

# History + options
[[ -d ~/.local/state/zsh ]] && HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS
setopt NOBEEP NUMERIC_GLOB_SORT

source "$ZDOTDIR/fzf.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/keybinds.zsh"
source "$ZDOTDIR/nvm.zsh"

# Completions
autoload -Uz compinit
compinit -C -d "$XDG_CACHE_HOME/zsh/zcompdump"
source "$ZDOTDIR/completions.zsh"

# Load plugins
source "$ZDOTDIR/plugins.zsh"

zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':fzf-tab:*' use-compinit no

# Starship
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"
[ -f "$ZDOTDIR/starship.toml" ] && eval "$(starship init zsh)"

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
