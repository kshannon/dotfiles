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
stow zsh git tmux starship ghostty nvim claude-code pixi ssh
```

## Repository Structure

```
~/dev/dotfiles/
├── zsh/                    # Shell config (.zshrc, .zprofile, .zshenv)
├── git/                    # Git config
├── tmux/                   # Tmux config
├── starship/               # Prompt config
├── ghostty/                # Terminal config
├── nvim/                   # Neovim config
├── claude-code/            # Claude Code settings
├── pixi/                   # Pixi environments
├── ssh/                    # SSH config
├── brew/
│   ├── Brewfile.common     # Shared packages (all machines)
│   ├── Brewfile.studio     # Mac Studio specific
│   ├── Brewfile.air        # MacBook Air specific
│   └── MANUAL.md           # DMG-installed apps tracking
└── scripts/
    ├── bootstrap.sh        # Fresh machine setup
    ├── dotfiles-doctor.sh  # Drift detection
    └── com.kyle.dotfiles-doctor.plist
```

## Daily Workflow

### Commands

These commands are available after stowing `zsh/`:

| Command | Description |
|---------|-------------|
| `dot` | Quick status + workflow guide |
| `dothelp` | Full command reference |
| `dotpull` | Pull latest dotfiles (fast-forward only) |
| `dotpush` | Push dotfiles to remote |
| `dotstatus` | Show dotfiles git status |
| `dotfiles-doctor` | Run drift detection (`-v` for verbose) |
| `brewdump` | Capture current Homebrew state to Brewfile |
| `brewcheck` | Check what's missing from Brewfile |
| `brewinstall` | Install packages from Brewfile |

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

A daily LaunchAgent runs `dotfiles-doctor.sh` at 9 AM. If drift is detected, you'll see a warning when opening a new terminal:

```
[dotfiles] sync needed · run dot for commands
```

Run `dotfiles-doctor -v` for details:
- Uncommitted changes
- Commits behind/ahead of origin
- Packages not in Brewfile (with add/remove guidance)
- Brewfile packages not installed

## Homebrew Strategy

### Brewfile as Capture (Not Enforced)

The Brewfile records what's installed - it's a snapshot, not a strict source of truth. We never run `brew bundle cleanup` automatically.

- `brewdump` - Captures current state
- `brewcheck` - Shows what differs
- `brewinstall` - Installs missing packages (doesn't remove extras)

### Homebrew vs DMG

| App Type | Install Method | Examples |
|----------|----------------|----------|
| No self-update | Homebrew cask | ghostty, kap, stats, raycast |
| Self-updates aggressively | DMG | Arc, Firefox, Chrome, VS Code |
| Paid/licensed | DMG | Rectangle Pro, 1Password |

See `brew/MANUAL.md` for the full list of DMG-installed apps.

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
| `ghostty` | `.config/ghostty/config` |
| `nvim` | `.config/nvim/init.lua` |
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
