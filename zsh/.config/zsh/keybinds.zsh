set -o vi
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey ' ' magic-space

bindkey -s '^Xgcfi' 'git commit -m "fix: "\C-[i'
bindkey -s '^Xgcfe' 'git commit -m "feat: "\C-[i'
bindkey -s '^Xgcc' 'git commit -m "chore: "\C-[i'
bindkey -s '^Xgcb' 'git commit -m "build: "\C-[i'
bindkey -s '^Xgcd' 'git commit -m "docs: "\C-[i'
