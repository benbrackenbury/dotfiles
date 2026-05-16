if command -v fd >/dev/null 2>&1; then
	export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
elif command -v fdfind >/dev/null 2>&1; then
	export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --strip-cwd-prefix'
fi

export FZF_DEFAULT_OPTS='--height ~40% --layout=reverse --border'

if [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
    return
fi
if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    source /usr/share/doc/fzf/examples/completion.zsh
    return
fi
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    source /opt/homebrew/opt/fzf/shell/completion.zsh
    return
fi
