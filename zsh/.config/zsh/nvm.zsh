# NVM lazy loading
#
# Keeps zsh startup fast while preventing automatic version switching from .nvmrc files.
#
# - nvm (and node/npm/npx) are only loaded the first time they are used in a session
# - Uses --no-use so project .nvmrc files are completely ignored
# - Always activates your `nvm alias default` on first load
# - You must explicitly run `nvm use` (or `nvm use 20`) to change versions

export NVM_DIR="$HOME/.nvm"

__load_nvm() {
    unset -f nvm node npm npx __load_nvm
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" --no-use
    nvm use --silent default 2>/dev/null || true
}

nvm()  { __load_nvm; nvm "$@"; }
node() { __load_nvm; command node "$@"; }
npm()  { __load_nvm; command npm  "$@"; }
npx()  { __load_nvm; command npx  "$@"; }
