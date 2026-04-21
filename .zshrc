cowsay -f stegosaurus 'Good day sir'

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

eval $(thefuck --alias)

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export SSH_SK_PROVIDER=/usr/local/lib/libsk-libfido2.dylib

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

eval "$(zoxide init zsh --cmd cd)"

# Make fzf source candidates from `fd` (respects .gitignore/.ignore by default).
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --hidden --type f --strip-cwd-prefix --exclude .git --exclude node_modules --exclude Library --exclude .cache --exclude .docker --exclude .orbstack --exclude OrbStack --exclude .Trash'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --hidden --type d --strip-cwd-prefix --exclude .git --exclude node_modules --exclude Library --exclude .cache --exclude .docker --exclude .orbstack --exclude OrbStack --exclude .Trash'
fi

source <(fzf --zsh)

# pnpm
export PNPM_HOME="/Users/leon.stoelt/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Completion setup.
autoload -Uz compinit bashcompinit
compinit
bashcompinit
# Include hidden files/dirs in path completion (e.g. `nvim <TAB>`).
_comp_options+=(globdots)

# pnpm completions (includes local package.json scripts for `pnpm run`).
if command -v pnpm >/dev/null 2>&1; then
  eval "$(pnpm completion zsh)"
fi

# npm exposes bash completion.
if command -v npm >/dev/null 2>&1; then
  eval "$(npm completion 2>/dev/null)"
fi

# Ensure makefile targets complete for make/gmake.
autoload -Uz _make
compdef _make make gmake

# Yarn v1: complete `yarn run <script>` from local package.json scripts.
_yarn_local_scripts_completion() {
  local -a scripts
  if (( CURRENT == 3 )) && [[ "${words[2]}" == "run" || "${words[2]}" == "run-script" ]]; then
    if [[ -f package.json ]] && command -v node >/dev/null 2>&1; then
      scripts=(${(f)"$(node -e 'const fs=require(\"fs\");try{const p=JSON.parse(fs.readFileSync(\"package.json\",\"utf8\"));const s=p&&p.scripts?p.scripts:{};for(const k of Object.keys(s))console.log(k)}catch(_){ }' 2>/dev/null)"})
      (( ${#scripts} )) && _describe 'yarn scripts' scripts && return 0
    fi
  fi
  _default
}
compdef _yarn_local_scripts_completion yarn

# Composer exposes bash completion only.
if command -v composer >/dev/null 2>&1; then
  eval "$(composer completion bash 2>/dev/null)"
fi

# Optional extras: enabled only when the tool exists.
if command -v gh >/dev/null 2>&1; then
  eval "$(gh completion -s zsh)"
fi

if command -v docker >/dev/null 2>&1; then
  eval "$(docker completion zsh)"
fi

if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

# Fuzzy completion menu.
FZF_TAB_FILE="$(brew --prefix fzf-tab 2>/dev/null)/share/fzf-tab/fzf-tab.zsh"
if [ -f "$FZF_TAB_FILE" ]; then
  source "$FZF_TAB_FILE"
fi

# Use TAB like Alt+C on an empty prompt (directory picker), otherwise run completion via fzf-tab.
_tab_or_fzf_file_widget() {
  if [[ -z "${LBUFFER}${RBUFFER}" ]]; then
    zle fzf-cd-widget
  else
    zle fzf-tab-complete
  fi
}
zle -N _tab_or_fzf_file_widget
bindkey -M emacs '^I' _tab_or_fzf_file_widget
bindkey -M viins '^I' _tab_or_fzf_file_widget
bindkey -M main '^I' _tab_or_fzf_file_widget

# Inline history suggestions.
ZSH_AUTOSUGGESTIONS_FILE="$(brew --prefix zsh-autosuggestions 2>/dev/null)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
if [ -f "$ZSH_AUTOSUGGESTIONS_FILE" ]; then
  source "$ZSH_AUTOSUGGESTIONS_FILE"
  # Keep Right Arrow for cursor movement (default zle widget).
  bindkey '^[[C' forward-char
  bindkey '^[OC' forward-char
fi

if [[ -S "$SSH_AUTH_SOCK" ]]; then
  :
else
  export SSH_AUTH_SOCK="$HOME/.ssh/agent"
fi

export SSH_SK_PROVIDER=/usr/local/lib/libsk-libfido2.dylib
export PATH="$HOME/.local/bin:$PATH"
