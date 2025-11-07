# ~/.zshrc
# Loaded for INTERACTIVE shells only

#############################
# OPTIONS
#############################

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY           # Append to history file
setopt SHARE_HISTORY            # Share history between sessions
setopt HIST_IGNORE_DUPS         # Don't record duplicates
setopt HIST_IGNORE_SPACE        # Don't record commands starting with space
setopt HIST_REDUCE_BLANKS       # Remove extra blanks from history

# Directory navigation
setopt AUTO_CD                  # Type directory name to cd
setopt AUTO_PUSHD               # Push directories to stack
setopt PUSHD_IGNORE_DUPS        # Don't push duplicates
setopt PUSHD_SILENT             # Don't print directory stack

# Completion
setopt COMPLETE_IN_WORD         # Complete from both ends of word
setopt ALWAYS_TO_END            # Move cursor to end after completion
setopt AUTO_MENU                # Show completion menu on tab
setopt AUTO_LIST                # List choices on ambiguous completion

# Other useful options
setopt INTERACTIVE_COMMENTS     # Allow comments in interactive shells
setopt EXTENDED_GLOB            # Enable extended globbing

#############################
# COMPLETION SYSTEM
#############################

autoload -Uz compinit
# Only check cache once per day for speed
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # Colored completion

#############################
# KEY BINDINGS
#############################

# Emacs-style key bindings (can change to 'bindkey -v' for vi mode)
bindkey -v

# Better history search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search    # Up arrow
bindkey '^[[B' down-line-or-beginning-search  # Down arrow

#############################
# ALIASES
#############################

# Reload zsh config
alias rz='source ~/.zshrc && echo "✓ Zsh config reloaded"'

# ls aliases (macOS/BSD style)
alias ls='ls -G'
alias ll='ls -lh'
alias la='ls -A'
alias l='ls -CF'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Clear
alias c='clear'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gca='git commit -a'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gl='git log --oneline --graph --decorate'
alias gla='git log --oneline --graph --decorate --all'

# Development
alias py='python3'
alias ipy='ipython'

# Utility
alias weather='curl wttr.in'
alias myip='curl ifconfig.me'

#############################
# TOOL INITIALIZATION
#############################

# NVM (Node Version Manager)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# chruby (Ruby Version Manager)
if [[ -f "/opt/homebrew/opt/chruby/share/chruby/chruby.sh" ]]; then
    source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
    source /opt/homebrew/opt/chruby/share/chruby/auto.sh
fi

# fzf (Fuzzy Finder) - install with: brew install fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Starship prompt - MUST BE AT END
# Install with: brew install starship
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Pixi completion
eval "$(pixi completion --shell zsh)"

###############################
# PROJECT-SPECIFIC ENV EXPORTS
###############################

# Claude Code
export DISABLE_AUTOUPDATER=1
export EDITOR='code'

# Rails/Ruby specific
# export FONTAWESOME_NPM_AUTH_TOKEN="FONTAWESOME_NPM_AUTH_TOKEN"

# Project-specific PATHs here
# export PATH="$PATH:/your/custom/path"

#############################
# PIXI HELPERS
#############################

alias py='pixi run --manifest-path ~/pixi-envs/base/pixi.toml python'
alias ipy='pixi run --manifest-path ~/pixi-envs/base/pixi.toml ipython'
alias jup='pixi run --manifest-path ~/pixi-envs/base/pixi.toml jupyter lab'

