#!/usr/bin/env bash
#
# bootstrap.sh - Set up a fresh Mac from this dotfiles repo
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kshannon/dotfiles/main/scripts/bootstrap.sh | bash
#   OR
#   git clone https://github.com/kshannon/dotfiles.git ~/dev/dotfiles && ~/dev/dotfiles/scripts/bootstrap.sh
#

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dev/dotfiles}"
HOSTNAME=$(hostname -s | tr '[:upper:]' '[:lower:]')

echo "==> Dotfiles Bootstrap"
echo "    Machine: $HOSTNAME"
echo ""

#############################
# 1. Clone if needed
#############################
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "==> Cloning dotfiles..."
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    git clone https://github.com/kshannon/dotfiles.git "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

#############################
# 2. Install Homebrew if needed
#############################
if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to path for this session
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

#############################
# 3. Install Stow if needed
#############################
if ! command -v stow &>/dev/null; then
    echo "==> Installing GNU Stow..."
    brew install stow
fi

#############################
# 4. Install from Brewfiles
#############################
echo "==> Installing Homebrew packages..."
brew bundle --file="$DOTFILES_DIR/brew/Brewfile.common" --no-upgrade

# Install machine-specific if exists
MACHINE_BREWFILE="$DOTFILES_DIR/brew/Brewfile.$HOSTNAME"
if [[ -f "$MACHINE_BREWFILE" ]]; then
    echo "==> Installing $HOSTNAME-specific packages..."
    brew bundle --file="$MACHINE_BREWFILE" --no-upgrade
fi

#############################
# 5. Stow packages
#############################
echo "==> Stowing dotfiles..."
cd "$DOTFILES_DIR"

# List of packages to stow (add/remove as needed)
packages=(
    zsh
    git
    tmux
    starship
    claude-code
    pixi
    ssh
)

for pkg in "${packages[@]}"; do
    if [[ -d "$pkg" ]]; then
        echo "    Stowing $pkg..."
        stow --restow "$pkg" 2>/dev/null || stow "$pkg"
    fi
done

#############################
# 6. Install LaunchAgent
#############################
echo "==> Installing LaunchAgent for dotfiles-doctor..."
mkdir -p ~/Library/LaunchAgents
cp "$DOTFILES_DIR/scripts/com.kyle.dotfiles-doctor.plist" ~/Library/LaunchAgents/ 2>/dev/null || true
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.kyle.dotfiles-doctor.plist 2>/dev/null || true

#############################
# Done
#############################
echo ""
echo "==> Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (or: source ~/.zshrc)"
echo "  2. Run: dotfiles-doctor -v"
echo "  3. Check brew/MANUAL.md for apps to install manually"
echo ""
