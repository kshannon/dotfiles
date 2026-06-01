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
# DOTFILES & BREW SYNC
#############################

# Quick status and workflow
dot() {
    echo ""
    echo "  \033[1;33m📁 Dotfiles Status\033[0m"
    echo "  ─────────────────────────────────────────"
    git -C ~/dev/dotfiles status --short 2>/dev/null | head -5 | sed 's/^/  /'
    local ahead=$(git -C ~/dev/dotfiles rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
    local behind=$(git -C ~/dev/dotfiles rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
    [[ "$ahead" -gt 0 ]] && echo "  ⇡ $ahead commit(s) to push"
    [[ "$behind" -gt 0 ]] && echo "  ⇣ $behind commit(s) to pull"
    echo ""
    echo "  \033[1;33m📋 Workflow\033[0m"
    echo "  ─────────────────────────────────────────"
    echo "  1. \033[0;36mdotpull\033[0m          Pull latest changes"
    echo "  2. \033[0;36mbrewinstall\033[0m      Install missing packages"
    echo "  3. \033[0;36mstow --restow */\033[0m Refresh symlinks"
    echo "  4. \033[0;36mbrewdump\033[0m         Capture new installs"
    echo "  5. \033[0;36mdotpush\033[0m          Push your changes"
    echo ""
    echo "  Run \033[0;36mdothelp\033[0m for all commands"
    echo ""
}

# Full command reference
dothelp() {
    echo ""
    echo "  \033[1;33mDotfiles Commands\033[0m"
    echo "  ─────────────────────────────────────────"
    echo "  \033[1;36mdot\033[0m              Quick status + workflow"
    echo "  \033[1;36mdothelp\033[0m          Show this command reference"
    echo "  \033[1;36mdotstatus\033[0m        Git status of dotfiles repo"
    echo "  \033[1;36mdotpull\033[0m          Pull latest dotfiles"
    echo "  \033[1;36mdotpush\033[0m          Push dotfiles to remote"
    echo "  \033[1;36mdotfiles-doctor\033[0m  Check for drift (-v for details)"
    echo ""
    echo "  \033[1;33mBrewfile Commands\033[0m"
    echo "  ─────────────────────────────────────────"
    echo "  \033[1;36mbrewdump\033[0m         Capture current brew state"
    echo "  \033[1;36mbrewcheck\033[0m        Check what's missing"
    echo "  \033[1;36mbrewinstall\033[0m      Install from Brewfile"
    echo ""
}

# Brewfile management
alias brewdump='brew bundle dump --describe --force --file=~/dev/dotfiles/brew/Brewfile.common && echo "Brewfile.common updated"'
alias brewcheck='brew bundle check --verbose --file=~/dev/dotfiles/brew/Brewfile.common'
alias brewinstall='brew bundle --file=~/dev/dotfiles/brew/Brewfile.common'

# Dotfiles sync
alias dotpull='git -C ~/dev/dotfiles pull --ff-only'
alias dotstatus='git -C ~/dev/dotfiles status'
alias dotpush='git -C ~/dev/dotfiles push'
alias dotfiles-doctor='~/dev/dotfiles/scripts/dotfiles-doctor.sh'

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

# Latex
export PATH="/Library/TeX/texbin:$PATH"

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

#############################
# DOTFILES DOCTOR STATUS
#############################

# Simple drift indicator on login
_dotfiles_status_file="$HOME/.cache/dotfiles-doctor.status"
if [[ -f "$_dotfiles_status_file" ]]; then
    _status_type=$(cut -d'|' -f2 < "$_dotfiles_status_file")
    if [[ "$_status_type" == "drift" ]]; then
        echo -e "\033[0;33m[dotfiles]\033[0m sync needed · run \033[0;36mdot\033[0m for commands"
    fi
    unset _status_type
fi

