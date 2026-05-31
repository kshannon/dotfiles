# Machine Sync Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Keep Mac Studio and MacBook Air development environments in sync with alert-only drift detection, Brewfile capture, and explicit pull workflow.

**Architecture:** GNU Stow for dotfiles (keep existing), Brewfile as capture (not enforced source of truth), launchd-scheduled drift detection script that reports but never auto-fixes, terminal MOTD for visibility.

**Tech Stack:** GNU Stow, Homebrew Bundle, launchd, zsh, terminal-notifier

---

## Stage 0: Foundation (Today)

### Task 1: Create Brewfile from Current State

**Files:**
- Create: `brew/Brewfile.common`

**Step 1: Create brew directory**

```bash
mkdir -p ~/dev/dotfiles/brew
```

**Step 2: Dump current Homebrew state with descriptions**

```bash
brew bundle dump --describe --file=~/dev/dotfiles/brew/Brewfile.common --force
```

**Step 3: Review the generated file**

Open `brew/Brewfile.common` and verify it captured your 207 formulae and 14 casks.

**Step 4: Commit**

```bash
cd ~/dev/dotfiles
git add brew/Brewfile.common
git commit -m "feat: add Brewfile.common with current homebrew state"
```

---

### Task 2: Add Brew and Dotfiles Aliases to Zsh

**Files:**
- Modify: `zsh/.zshrc`

**Step 1: Add aliases section to .zshrc**

Add after the existing aliases section:

```zsh
#############################
# DOTFILES & BREW SYNC
#############################

# Brewfile management
alias brewdump='brew bundle dump --describe --force --file=~/dev/dotfiles/brew/Brewfile.common && echo "Brewfile.common updated"'
alias brewcheck='brew bundle check --verbose --file=~/dev/dotfiles/brew/Brewfile.common'
alias brewinstall='brew bundle --file=~/dev/dotfiles/brew/Brewfile.common'

# Dotfiles sync
alias dotpull='git -C ~/dev/dotfiles pull --ff-only'
alias dotstatus='git -C ~/dev/dotfiles status'
alias dotpush='git -C ~/dev/dotfiles push'
```

**Step 2: Commit**

```bash
cd ~/dev/dotfiles
git add zsh/.zshrc
git commit -m "feat: add brew and dotfiles sync aliases"
```

---

### Task 3: Fix Claude Code Update Nag

**Files:**
- Modify: `claude-code/.claude/settings.json`

**Step 1: Read current settings**

Check current contents of `.claude/settings.json`.

**Step 2: Add autoUpdatesChannel setting**

Add `"autoUpdatesChannel": "stable"` to the settings JSON.

**Step 3: Commit**

```bash
cd ~/dev/dotfiles
git add claude-code/.claude/settings.json
git commit -m "fix: set claude-code to stable channel to stop update nag"
```

---

### Task 4: Update .stow-local-ignore

**Files:**
- Create or modify: `.stow-local-ignore`

**Step 1: Create/update .stow-local-ignore at repo root**

This prevents `stow */` from trying to symlink non-package directories:

```
# Directories that aren't stow packages
brew
docs
scripts

# Files at root
README.md
LICENSE
SYNC-PLANNING.md
\.git
\.gitignore
```

**Step 2: Commit**

```bash
cd ~/dev/dotfiles
git add .stow-local-ignore
git commit -m "chore: add .stow-local-ignore for non-package dirs"
```

---

## Stage 1: Drift Detection (This Week)

### Task 5: Create dotfiles-doctor Script

**Files:**
- Create: `scripts/dotfiles-doctor.sh`

**Step 1: Create scripts directory**

```bash
mkdir -p ~/dev/dotfiles/scripts
```

**Step 2: Write the doctor script**

Create `scripts/dotfiles-doctor.sh`:

```bash
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
```

**Step 3: Make executable**

```bash
chmod +x ~/dev/dotfiles/scripts/dotfiles-doctor.sh
```

**Step 4: Test it**

```bash
~/dev/dotfiles/scripts/dotfiles-doctor.sh -v
```

**Step 5: Commit**

```bash
cd ~/dev/dotfiles
git add scripts/dotfiles-doctor.sh
git commit -m "feat: add dotfiles-doctor drift detection script"
```

---

### Task 6: Add MOTD to Zsh

**Files:**
- Modify: `zsh/.zshrc`

**Step 1: Add doctor status check to .zshrc**

Add at the END of `.zshrc`, after starship init:

```zsh
#############################
# DOTFILES DOCTOR STATUS
#############################

# Show drift warning on login if status file indicates issues
_dotfiles_status_file="$HOME/.cache/dotfiles-doctor.status"
if [[ -f "$_dotfiles_status_file" ]]; then
    _status_line=$(cat "$_dotfiles_status_file")
    _status_type=$(echo "$_status_line" | cut -d'|' -f2)
    _status_msg=$(echo "$_status_line" | cut -d'|' -f3-)
    _status_time=$(echo "$_status_line" | cut -d'|' -f1)

    if [[ "$_status_type" == "drift" ]]; then
        echo -e "\033[0;33m[dotfiles]\033[0m $_status_msg"
        echo -e "          Run \033[0;36mdotfiles-doctor -v\033[0m for details"
    fi
    unset _status_line _status_type _status_msg _status_time
fi
```

**Step 2: Add doctor alias**

Add to the DOTFILES & BREW SYNC section:

```zsh
alias dotfiles-doctor='~/dev/dotfiles/scripts/dotfiles-doctor.sh'
```

**Step 3: Commit**

```bash
cd ~/dev/dotfiles
git add zsh/.zshrc
git commit -m "feat: add dotfiles doctor MOTD and alias"
```

---

### Task 7: Create LaunchAgent for Daily Doctor

**Files:**
- Create: `scripts/com.kyle.dotfiles-doctor.plist`

**Step 1: Create the plist**

Create `scripts/com.kyle.dotfiles-doctor.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.kyle.dotfiles-doctor</string>

    <key>ProgramArguments</key>
    <array>
        <string>/Users/kyle/dev/dotfiles/scripts/dotfiles-doctor.sh</string>
    </array>

    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>9</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>

    <key>RunAtLoad</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/tmp/dotfiles-doctor.log</string>

    <key>StandardErrorPath</key>
    <string>/tmp/dotfiles-doctor.err</string>
</dict>
</plist>
```

**Step 2: Commit the plist to repo**

```bash
cd ~/dev/dotfiles
git add scripts/com.kyle.dotfiles-doctor.plist
git commit -m "feat: add launchd plist for daily doctor runs"
```

**Step 3: Install the LaunchAgent**

```bash
cp ~/dev/dotfiles/scripts/com.kyle.dotfiles-doctor.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.kyle.dotfiles-doctor.plist
```

**Step 4: Test it runs**

```bash
launchctl kickstart gui/$(id -u)/com.kyle.dotfiles-doctor
cat /tmp/dotfiles-doctor.log
```

---

### Task 8: Create Machine-Specific Brewfiles

**Files:**
- Create: `brew/Brewfile.studio`
- Create: `brew/Brewfile.air`
- Create: `brew/MANUAL.md`

**Step 1: Create empty machine-specific Brewfiles**

For now, create placeholders. Move packages from Brewfile.common as you identify machine-specific ones:

`brew/Brewfile.studio`:
```ruby
# Mac Studio specific packages
# Move entries here from Brewfile.common that are Studio-only

# Example (uncomment and move from common):
# cask "some-heavy-app"
```

`brew/Brewfile.air`:
```ruby
# MacBook Air specific packages
# Move entries here from Brewfile.common that are Air-only

# Example (uncomment and move from common):
# cask "some-mobile-app"
```

**Step 2: Create MANUAL.md for DMG-installed apps**

`brew/MANUAL.md`:
```markdown
# Manually Installed Applications

Apps installed via DMG/direct download (not Homebrew).
Track these here so they're not forgotten during machine setup.

## Format

| App | Source | Why not Homebrew? | Update Method |
|-----|--------|-------------------|---------------|
| Example App | https://example.com | No cask available | In-app updater |

## Current Manual Apps

| App | Source | Why not Homebrew? | Update Method |
|-----|--------|-------------------|---------------|
| *None yet* | | | |

<!-- Add apps as you identify them -->
```

**Step 3: Commit**

```bash
cd ~/dev/dotfiles
git add brew/Brewfile.studio brew/Brewfile.air brew/MANUAL.md
git commit -m "feat: add machine-specific Brewfiles and MANUAL.md"
```

---

### Task 9: Install terminal-notifier

**Step 1: Install via Homebrew**

```bash
brew install terminal-notifier
```

**Step 2: Update Brewfile**

```bash
brewdump
```

**Step 3: Commit**

```bash
cd ~/dev/dotfiles
git add brew/Brewfile.common
git commit -m "chore: add terminal-notifier to Brewfile"
```

---

## Stage 2: Polish (This Month)

### Task 10: Create Bootstrap Script

**Files:**
- Create: `scripts/bootstrap.sh`

**Step 1: Write bootstrap script**

Create `scripts/bootstrap.sh`:

```bash
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
```

**Step 2: Make executable**

```bash
chmod +x ~/dev/dotfiles/scripts/bootstrap.sh
```

**Step 3: Commit**

```bash
cd ~/dev/dotfiles
git add scripts/bootstrap.sh
git commit -m "feat: add bootstrap script for fresh machine setup"
```

---

### Task 11: Add Pre-Push Hook for Brewfile

**Files:**
- Create: `.githooks/pre-push`

**Step 1: Create githooks directory**

```bash
mkdir -p ~/dev/dotfiles/.githooks
```

**Step 2: Create pre-push hook**

Create `.githooks/pre-push`:

```bash
#!/usr/bin/env bash
#
# pre-push hook: refresh Brewfile before pushing
#

DOTFILES_DIR="$(git rev-parse --show-toplevel)"
BREWFILE="$DOTFILES_DIR/brew/Brewfile.common"

if command -v brew &>/dev/null && [[ -f "$BREWFILE" ]]; then
    echo "[pre-push] Refreshing Brewfile.common..."
    brew bundle dump --describe --force --file="$BREWFILE"

    if ! git diff --quiet "$BREWFILE"; then
        echo "[pre-push] Brewfile updated. Adding to commit..."
        git add "$BREWFILE"
        git commit --amend --no-edit
    fi
fi
```

**Step 3: Make executable**

```bash
chmod +x ~/dev/dotfiles/.githooks/pre-push
```

**Step 4: Configure git to use this hooks directory**

Add to `git/.gitconfig`:

```ini
[core]
    hooksPath = ~/dev/dotfiles/.githooks
```

Or run:

```bash
git config --local core.hooksPath .githooks
```

**Step 5: Commit**

```bash
cd ~/dev/dotfiles
git add .githooks/pre-push
git commit -m "feat: add pre-push hook to auto-refresh Brewfile"
```

---

### Task 12: Update README.md

**Files:**
- Modify: `README.md`

**Step 1: Rewrite README with complete documentation**

Update `README.md` to document:
- Quick start / bootstrap instructions
- Stow packages available
- Brew sync workflow (aliases, brewdump, brewcheck)
- Drift detection (dotfiles-doctor)
- Cask policy (auto_updates vs managed)
- Machine-specific setup
- Pull workflow (dotpull)

**Step 2: Commit**

```bash
cd ~/dev/dotfiles
git add README.md
git commit -m "docs: comprehensive README with sync workflow"
```

---

## Execution Checklist

- [ ] Task 1: Create Brewfile from Current State
- [ ] Task 2: Add Brew and Dotfiles Aliases to Zsh
- [ ] Task 3: Fix Claude Code Update Nag
- [ ] Task 4: Update .stow-local-ignore
- [ ] Task 5: Create dotfiles-doctor Script
- [ ] Task 6: Add MOTD to Zsh
- [ ] Task 7: Create LaunchAgent for Daily Doctor
- [ ] Task 8: Create Machine-Specific Brewfiles
- [ ] Task 9: Install terminal-notifier
- [ ] Task 10: Create Bootstrap Script
- [ ] Task 11: Add Pre-Push Hook for Brewfile
- [ ] Task 12: Update README.md

---

## After All Tasks

1. **Push everything**: `git push`
2. **Test on MacBook Air**: Clone repo, run `scripts/bootstrap.sh`
3. **Verify doctor works**: Check MOTD appears on terminal login
4. **Document any DMG apps** you find in `brew/MANUAL.md`
