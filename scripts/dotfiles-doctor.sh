#!/usr/bin/env bash
#
# dotfiles-doctor.sh - Alert-only drift detection
# Reports differences but NEVER auto-fixes anything
#

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dev/dotfiles}"
BREWFILE_COMMON="$DOTFILES_DIR/brew/Brewfile.common"
STATUS_FILE="$HOME/.cache/dotfiles-doctor.status"
VERBOSE="${1:-}"

# Ensure cache dir exists
mkdir -p "$(dirname "$STATUS_FILE")"

# Colors (only if terminal)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    GREEN='\033[0;32m'
    NC='\033[0m'
else
    RED='' YELLOW='' GREEN='' NC=''
fi

issues=()
warnings=()

#############################
# Check 1: Git status (uncommitted changes)
#############################
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    git_status=$(git -C "$DOTFILES_DIR" status --porcelain 2>/dev/null || true)
    if [[ -n "$git_status" ]]; then
        count=$(echo "$git_status" | wc -l | tr -d ' ')
        issues+=("$count uncommitted dotfile change(s)")
        if [[ "$VERBOSE" == "-v" ]]; then
            echo -e "${YELLOW}Uncommitted changes:${NC}"
            echo "$git_status"
        fi
    fi
fi

#############################
# Check 2: Git behind upstream
#############################
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    git -C "$DOTFILES_DIR" fetch --quiet 2>/dev/null || true
    local_head=$(git -C "$DOTFILES_DIR" rev-parse HEAD 2>/dev/null || echo "none")
    upstream=$(git -C "$DOTFILES_DIR" rev-parse '@{u}' 2>/dev/null || echo "none")

    if [[ "$local_head" != "none" && "$upstream" != "none" && "$local_head" != "$upstream" ]]; then
        behind=$(git -C "$DOTFILES_DIR" rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
        ahead=$(git -C "$DOTFILES_DIR" rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
        if [[ "$behind" -gt 0 ]]; then
            issues+=("$behind commit(s) behind origin")
        fi
        if [[ "$ahead" -gt 0 ]]; then
            warnings+=("$ahead commit(s) ahead of origin (push pending)")
        fi
    fi
fi

#############################
# Check 3: Brew packages not in Brewfile
#############################
if [[ -f "$BREWFILE_COMMON" ]] && command -v brew &>/dev/null; then
    # Formulae
    installed_formulae=$(brew leaves 2>/dev/null | sort)
    brewfile_formulae=$(grep '^brew "' "$BREWFILE_COMMON" 2>/dev/null | sed 's/brew "//;s/".*//;s/@.*//' | sort || true)

    extra_formulae=$(comm -23 <(echo "$installed_formulae") <(echo "$brewfile_formulae") 2>/dev/null || true)
    if [[ -n "$extra_formulae" ]]; then
        count=$(echo "$extra_formulae" | wc -l | tr -d ' ')
        warnings+=("$count formula(e) installed but not in Brewfile")
        if [[ "$VERBOSE" == "-v" ]]; then
            echo -e "${YELLOW}Formulae not in Brewfile:${NC}"
            echo "$extra_formulae"
        fi
    fi

    # Casks
    installed_casks=$(brew list --cask 2>/dev/null | sort)
    brewfile_casks=$(grep '^cask "' "$BREWFILE_COMMON" 2>/dev/null | sed 's/cask "//;s/".*//;s/@.*//' | sort || true)

    extra_casks=$(comm -23 <(echo "$installed_casks") <(echo "$brewfile_casks") 2>/dev/null || true)
    if [[ -n "$extra_casks" ]]; then
        count=$(echo "$extra_casks" | wc -l | tr -d ' ')
        warnings+=("$count cask(s) installed but not in Brewfile")
        if [[ "$VERBOSE" == "-v" ]]; then
            echo -e "${YELLOW}Casks not in Brewfile:${NC}"
            echo "$extra_casks"
        fi
    fi
fi

#############################
# Check 4: Brewfile packages not installed
#############################
if [[ -f "$BREWFILE_COMMON" ]] && command -v brew &>/dev/null; then
    missing=$(brew bundle check --verbose --file="$BREWFILE_COMMON" 2>&1 | grep "needs to be installed" || true)
    if [[ -n "$missing" ]]; then
        count=$(echo "$missing" | wc -l | tr -d ' ')
        issues+=("$count Brewfile package(s) not installed")
        if [[ "$VERBOSE" == "-v" ]]; then
            echo -e "${YELLOW}Missing from Brewfile:${NC}"
            echo "$missing"
        fi
    fi
fi

#############################
# Summary
#############################
timestamp=$(date '+%Y-%m-%d %H:%M')

if [[ ${#issues[@]} -eq 0 && ${#warnings[@]} -eq 0 ]]; then
    summary="All clear"
    echo "$timestamp|ok|$summary" > "$STATUS_FILE"
    if [[ "$VERBOSE" == "-v" ]]; then
        echo -e "${GREEN}Dotfiles doctor: All clear${NC}"
    fi
    exit 0
fi

# Build summary
summary=""
if [[ ${#issues[@]} -gt 0 ]]; then
    summary+=$(IFS=', '; echo "${issues[*]}")
fi
if [[ ${#warnings[@]} -gt 0 ]]; then
    [[ -n "$summary" ]] && summary+="; "
    summary+=$(IFS=', '; echo "${warnings[*]}")
fi

echo "$timestamp|drift|$summary" > "$STATUS_FILE"

if [[ "$VERBOSE" == "-v" || -t 1 ]]; then
    echo -e "${YELLOW}Dotfiles doctor:${NC} $summary"
fi

# Send macOS notification if terminal-notifier available and not interactive
if ! [[ -t 1 ]] && command -v terminal-notifier &>/dev/null; then
    terminal-notifier -title "Dotfiles Drift" -message "$summary" -group "dotfiles-doctor" 2>/dev/null || true
fi

exit 1
