if [[ "$OSTYPE" == darwin* ]]; then
	alias ls='ls -GF'
else
	alias ls='ls -F --color=auto'
fi
alias l='ls -lah'
alias tree='tree -CF'
alias md='mkdir -p'
alias diff='diff --color=always'
alias less='less -R'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -ch'
alias fd='fd --glob --hidden'
alias mkdir='mkdir -p'

alias vi='nvim'
alias vim='nvim'
alias oc='opencode'
