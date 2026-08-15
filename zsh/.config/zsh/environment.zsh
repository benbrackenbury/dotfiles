export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export EDITOR="nvim"
export VISUAL="$EDITOR"

export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_AUTO_UPDATE=1

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.grok/bin:$PATH"

# ThemeKit: lazygit / bat pick up generated colours
if [[ -f "${XDG_STATE_HOME}/themekit/lazygit.yml" ]]; then
	_tk_lg="${XDG_STATE_HOME}/themekit/lazygit.yml"
	_tk_lg_user="${HOME}/Library/Application Support/lazygit/config.yml"
	[[ -f "${_tk_lg_user}" ]] || _tk_lg_user="${XDG_CONFIG_HOME}/lazygit/config.yml"
	if [[ -n "${LG_CONFIG_FILE:-}" ]]; then
		export LG_CONFIG_FILE="${LG_CONFIG_FILE},${_tk_lg}"
	elif [[ -f "${_tk_lg_user}" ]]; then
		export LG_CONFIG_FILE="${_tk_lg_user},${_tk_lg}"
	else
		export LG_CONFIG_FILE="${_tk_lg}"
	fi
	unset _tk_lg _tk_lg_user
fi
if [[ -f "${XDG_CONFIG_HOME}/bat/themes/themekit.tmTheme" ]]; then
	export BAT_THEME="themekit"
fi
