# Instant node, deferred nvm
#
# Node/npm/npx are on PATH immediately (newest installed version).
# nvm.sh is sourced after the prompt, or on first `nvm`, so new TTYs are not blocked.
# --no-use: project .nvmrc files do not auto-switch. Run `nvm use` to change versions.

export NVM_DIR="$HOME/.nvm"

_nvm_bin=($NVM_DIR/versions/node/*/bin(Nn[-1]))
(( $#_nvm_bin )) && PATH="$_nvm_bin:$PATH"
unset _nvm_bin

__load_nvm() {
    unset -f nvm __load_nvm
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" --no-use
}

nvm() { __load_nvm; nvm "$@"; }

# Source nvm in this shell once it is idle, without delaying the first prompt.
zmodload zsh/sched
sched +1 '(( $+functions[__load_nvm] )) && __load_nvm'
