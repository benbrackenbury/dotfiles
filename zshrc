export VISUAL=nvim
export EDITOR="$VISUAL"
export MANPAGER='nvim +Man! -'
export LESS=FR

# Vim Mode
set -o vi
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey '^R' history-incremental-search-backward

# Completion styling
autoload -Uz compinit; compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history)

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
export LESSHISTFILE=/dev/null

# Aliases
alias ls="ls -F --color=auto"
alias l="ls -lah"
alias tree='tree -CF'
alias vi="nvim"
alias vim="nvim"
alias vimm="/usr/bin/vim"

source "$HOME/dotfiles/bin/zsh-init-plugins"
init_plugins \
  "zsh-users/zsh-autosuggestions" \
  "zsh-users/zsh-completions" \
  "zsh-users/zsh-syntax-highlighting" \
  "Aloxaf/fzf-tab"

# Other options
export HOMEBREW_NO_AUTO_UPDATE=1

# Path
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:$HOME/.local/share/bob/nvim-bin/"
export PATH="$PATH:$HOME/.local/bin/"

# Initialize stuff
eval "$(starship init zsh)"
eval "$(~/.local/bin/mise activate)"

# Local overrides
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
