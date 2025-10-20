# ~/.zshenv

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Editor
export EDITOR="vim"
export VISUAL="vim"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"

# Ruby - enable YJIT (Rails Dev)
export RUBY_YJIT_ENABLE=1

# Homebrew (MacOS)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Language
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Less (pager) - better defaults
export LESS="-R -F -X"
export LESSHISTFILE="-"  # Don't save less history

# Colors for ls/grep
export CLICOLOR=1
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
