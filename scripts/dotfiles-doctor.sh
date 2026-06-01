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

# Colors
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    GREEN='\033[0;32m'
    CYAN='\033[0;36m'
    DIM='\033[2m'
    NC='\033[0m'
else
    RED='' YELLOW='' GREEN='' CYAN='' DIM='' NC=''
fi

issues=()
warnings=()
issue_count=0
warning_count=0

print_header() {
    echo ""
    echo -e "  ${YELLOW}$1${NC}"
    echo "  ─────────────────────────────────────────"
}

print_item() {
    local icon="$1"
    local text="$2"
    echo -e "  $icon $text"
}

#############################
# Check 1: Git status (uncommitted changes)
#############################
uncommitted_files=""
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    git_status=$(git -C "$DOTFILES_DIR" status --porcelain 2>/dev/null || true)
    if [[ -n "$git_status" ]]; then
        count=$(echo "$git_status" | wc -l | tr -d ' ')
        issues+=("$count uncommitted change(s)")
        uncommitted_files="$git_status"
        ((issue_count++))
    fi
fi

#############################
# Check 2: Git behind/ahead upstream
#############################
commits_behind=0
commits_ahead=0
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    git -C "$DOTFILES_DIR" fetch --quiet 2>/dev/null || true
    local_head=$(git -C "$DOTFILES_DIR" rev-parse HEAD 2>/dev/null || echo "none")
    upstream=$(git -C "$DOTFILES_DIR" rev-parse '@{u}' 2>/dev/null || echo "none")

    if [[ "$local_head" != "none" && "$upstream" != "none" && "$local_head" != "$upstream" ]]; then
        commits_behind=$(git -C "$DOTFILES_DIR" rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
        commits_ahead=$(git -C "$DOTFILES_DIR" rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
        if [[ "$commits_behind" -gt 0 ]]; then
            issues+=("$commits_behind commit(s) behind origin")
            ((issue_count++))
        fi
        if [[ "$commits_ahead" -gt 0 ]]; then
            warnings+=("$commits_ahead commit(s) ahead - push pending")
            ((warning_count++))
        fi
    fi
fi

#############################
# Check 3: Brew packages not in Brewfile
#############################
extra_formulae_list=""
extra_casks_list=""
if [[ -f "$BREWFILE_COMMON" ]] && command -v brew &>/dev/null; then
    installed_formulae=$(brew leaves 2>/dev/null | sort)
    brewfile_formulae=$(grep '^brew "' "$BREWFILE_COMMON" 2>/dev/null | sed 's/brew "//;s/".*//' | sort || true)
    extra_formulae_list=$(comm -23 <(echo "$installed_formulae") <(echo "$brewfile_formulae") 2>/dev/null || true)

    if [[ -n "$extra_formulae_list" ]]; then
        count=$(echo "$extra_formulae_list" | wc -l | tr -d ' ')
        warnings+=("$count formula(e) not in Brewfile")
        ((warning_count++))
    fi

    installed_casks=$(brew list --cask 2>/dev/null | sort)
    brewfile_casks=$(grep '^cask "' "$BREWFILE_COMMON" 2>/dev/null | sed 's/cask "//;s/".*//' | sort || true)
    extra_casks_list=$(comm -23 <(echo "$installed_casks") <(echo "$brewfile_casks") 2>/dev/null || true)

    if [[ -n "$extra_casks_list" ]]; then
        count=$(echo "$extra_casks_list" | wc -l | tr -d ' ')
        warnings+=("$count cask(s) not in Brewfile")
        ((warning_count++))
    fi
fi

#############################
# Check 4: Brewfile packages not installed
#############################
missing_packages=""
if [[ -f "$BREWFILE_COMMON" ]] && command -v brew &>/dev/null; then
    missing_packages=$(brew bundle check --verbose --file="$BREWFILE_COMMON" 2>&1 | grep "needs to be installed" || true)
    if [[ -n "$missing_packages" ]]; then
        count=$(echo "$missing_packages" | wc -l | tr -d ' ')
        issues+=("$count Brewfile package(s) not installed")
        ((issue_count++))
    fi
fi

#############################
# Output
#############################
timestamp=$(date '+%Y-%m-%d %H:%M')

if [[ ${#issues[@]} -eq 0 && ${#warnings[@]} -eq 0 ]]; then
    echo "$timestamp|ok|All clear" > "$STATUS_FILE"
    if [[ "$VERBOSE" == "-v" ]]; then
        echo ""
        echo -e "  ${GREEN}✓ Dotfiles: All clear${NC}"
        echo ""
    fi
    exit 0
fi

# Build summary for status file
summary=""
[[ ${#issues[@]} -gt 0 ]] && summary+=$(IFS=', '; echo "${issues[*]}")
if [[ ${#warnings[@]} -gt 0 ]]; then
    [[ -n "$summary" ]] && summary+="; "
    summary+=$(IFS=', '; echo "${warnings[*]}")
fi
echo "$timestamp|drift|$summary" > "$STATUS_FILE"

# Verbose output - formatted list
if [[ "$VERBOSE" == "-v" ]]; then
    print_header "Dotfiles Doctor"

    # Issues (red)
    if [[ -n "$uncommitted_files" ]]; then
        count=$(echo "$uncommitted_files" | wc -l | tr -d ' ')
        print_item "📝" "${RED}$count uncommitted change(s)${NC}"
        echo "$uncommitted_files" | sed 's/^/     /' | head -5
        [[ $(echo "$uncommitted_files" | wc -l) -gt 5 ]] && echo "     ..."
    fi

    if [[ "$commits_behind" -gt 0 ]]; then
        print_item "⇣" "${RED}$commits_behind commit(s) behind origin${NC} - run dotpull"
    fi

    if [[ -n "$missing_packages" ]]; then
        count=$(echo "$missing_packages" | wc -l | tr -d ' ')
        print_item "📦" "${RED}$count package(s) not installed${NC} - run brewinstall"
    fi

    # Warnings (yellow)
    if [[ "$commits_ahead" -gt 0 ]]; then
        print_item "⇡" "${YELLOW}$commits_ahead commit(s) ahead${NC} - run dotpush"
    fi

    if [[ -n "$extra_formulae_list" ]]; then
        count=$(echo "$extra_formulae_list" | wc -l | tr -d ' ')
        print_item "🍺" "${YELLOW}$count formula(e) not in Brewfile${NC} - run brewdump"
        echo "$extra_formulae_list" | sed 's/^/     /' | head -3
        [[ $(echo "$extra_formulae_list" | wc -l) -gt 3 ]] && echo "     ..."
    fi

    if [[ -n "$extra_casks_list" ]]; then
        count=$(echo "$extra_casks_list" | wc -l | tr -d ' ')
        print_item "📱" "${YELLOW}$count cask(s) not in Brewfile${NC} - run brewdump"
        echo "$extra_casks_list" | sed 's/^/     /' | head -3
        [[ $(echo "$extra_casks_list" | wc -l) -gt 3 ]] && echo "     ..."
    fi

    echo ""
    echo -e "  ${DIM}Run ${CYAN}dot${DIM} for workflow · ${CYAN}dothelp${DIM} for commands${NC}"
    echo ""
elif [[ -t 1 ]]; then
    # Brief output for interactive terminal (not -v)
    echo -e "${YELLOW}[dotfiles]${NC} $summary"
fi

# macOS notification for background runs
if ! [[ -t 1 ]] && command -v terminal-notifier &>/dev/null; then
    terminal-notifier -title "Dotfiles Drift" -message "$summary" -group "dotfiles-doctor" 2>/dev/null || true
fi

exit 1
