# Mole shell completion
if output="$(mole completion zsh 2>/dev/null)"; then eval "$output"; fi

# nvm completions
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Grok completions
if output="$(grok completion zsh 2>/dev/null)"; then eval "$output"; fi