# Dotfiles

Personal dotfiles and machine sync system for macOS. Uses GNU Stow for symlink management and Homebrew Bundle for package tracking.

## Quick Start

### Fresh Machine Setup

```bash
# Clone and bootstrap
git clone https://github.com/kshannon/dotfiles.git ~/dev/dotfiles
~/dev/dotfiles/scripts/bootstrap.sh
```

The bootstrap script will:
1. Install Homebrew (if needed)
2. Install GNU Stow
3. Install all packages from `Brewfile.common`
4. Install machine-specific packages (if `Brewfile.<hostname>` exists)
5. Stow all dotfile packages
6. Set up the daily drift detection LaunchAgent

### Existing Machine

```bash
cd ~/dev/dotfiles
stow zsh git tmux starship claude-code pixi ssh
```

## Repository Structure

```
~/dev/dotfiles/
├── zsh/                    # Stow package: shell config
├── git/                    # Stow package: git config
├── tmux/                   # Stow package: tmux config
├── starship/               # Stow package: prompt config
├── claude-code/            # Stow package: Claude Code settings
├── pixi/                   # Stow package: pixi environments
├── ssh/                    # Stow package: SSH config
├── brew/
│   ├── Brewfile.common     # Shared packages (all machines)
│   ├── Brewfile.studio     # Mac Studio specific
│   ├── Brewfile.air        # MacBook Air specific
│   └── MANUAL.md           # DMG-installed apps tracking
├── scripts/
│   ├── bootstrap.sh        # Fresh machine setup
│   ├── dotfiles-doctor.sh  # Drift detection
│   └── com.kyle.dotfiles-doctor.plist
└── docs/
    └── plans/              # Implementation plans
```

## Daily Workflow

### Aliases

These aliases are available after stowing `zsh/`:

| Alias | Description |
|-------|-------------|
| `brewdump` | Capture current Homebrew state to Brewfile |
| `brewcheck` | Check what's missing from Brewfile |
| `brewinstall` | Install packages from Brewfile |
| `dotpull` | Pull latest dotfiles (fast-forward only) |
| `dotstatus` | Show dotfiles git status |
| `dotpush` | Push dotfiles to remote |
| `dotfiles-doctor` | Run drift detection manually |

### Keeping Machines in Sync

**On the machine you're leaving:**
```bash
brewdump          # Capture any new brew installs
dotstatus         # Check for uncommitted changes
git add -A && git commit -m "update configs"
dotpush
```

**On the machine you're arriving at:**
```bash
dotpull           # Get latest changes
brewinstall       # Install any new packages
stow --restow */  # Re-stow if needed
```

### Drift Detection

A daily LaunchAgent runs `dotfiles-doctor.sh` at 9 AM and on login. If drift is detected, you'll see a warning when opening a new terminal:

```
[dotfiles] 2 uncommitted changes, 3 packages not in Brewfile
          Run dotfiles-doctor -v for details
```

Run `dotfiles-doctor -v` for verbose output showing exactly what's out of sync.

## Homebrew Strategy

### Brewfile as Capture (Not Enforced)

The Brewfile records what's installed - it's a snapshot, not a strict source of truth. We never run `brew bundle cleanup` automatically.

- `brewdump` - Captures current state
- `brewcheck` - Shows what differs
- `brewinstall` - Installs missing packages (doesn't remove extras)

### Cask Policy

| Cask Type | Update Method | Notes |
|-----------|---------------|-------|
| `auto_updates: true` | In-app updater | Homebrew won't upgrade these |
| `auto_updates: false` | `brew upgrade --cask` | Homebrew manages updates |

Most GUI apps (Raycast, Rectangle, Firefox, etc.) have `auto_updates: true` and self-update. That's fine - Homebrew is for installation and reproducibility, not necessarily updates.

### Machine-Specific Packages

Put host-only packages in `Brewfile.<hostname>`:
- `Brewfile.studio` - Mac Studio only
- `Brewfile.air` - MacBook Air only

The bootstrap script automatically installs the matching file.

## Stow Packages

| Package | Contents |
|---------|----------|
| `zsh` | `.zshrc`, `.zprofile`, `.zshenv` |
| `git` | `.gitconfig`, `.gitignore_global` |
| `tmux` | `.tmux.conf` |
| `starship` | `.config/starship.toml` |
| `claude-code` | `.claude/settings.json` |
| `pixi` | `pixi-envs/base/pixi.toml` |
| `ssh` | `.ssh/config` |

### Stowing and Unstowing

```bash
# Stow a package (creates symlinks)
stow zsh

# Restow (refresh symlinks)
stow --restow zsh

# Unstow (remove symlinks)
stow -D zsh
```

## Current Machines

- Mac Studio M2 Max (2023)
- MacBook Air

## Warnings

- Back up existing dotfiles before stowing
- Review configs before using - these are personalized
- Some GUI apps need manual configuration (see `brew/MANUAL.md`)
