# Dotfiles

My personal dotfiles and machine setup documentation for macOS and Linux. It is divided into three parts.
1. `dotfiles/packages/...` These are the actual package config dotfiles that Stow manages through symlinks
2. `dotfiles/docs/*.md` These are markdown files that provide additional configuration for tools, software, etc. that are developer based and non GUI oriented.
3. Wiki: The [wiki](https://github.com/kshannon/dotfiles/wiki) in this repo provides images and instructions for setting up non devloper centric software, e.g. how I set up my menu bar in mac os, and other ancillary tools. 

## Quick Start

### Prerequisites
- Git
- GNU Stow

### Installation

1. **Clone this repo to your home directory:**
```bash
   git clone https://github.com/kshannon/dotfiles.git ~/dotfiles
   cd ~/dotfiles
```

2. **Stow the packages you want:**
```bash
   # Stow everything
   stow */
   
   # Or stow individual packages
   stow zsh git nvim tmux
```

3. **Check the [Wiki/Setup Guide](./docs/new-machine-setup.md)** for additiona. OS specific machine setup instructions

## What's Included

### Configurations
- **Zsh**: ...

### Documentation
- Complete new machine setup guide
- Software installation lists (Homebrew + manual)
- macOS system preferences & GUI settings
- CLI tools and utilities
- Application-specific configurations

## Platform Support

- **Primary**: macOS (Apple Silicon)
- **Secondary**: Linux TBD

## 🔧 Usage

### Installing a new package
```bash
cd ~/dotfiles
stow package-name
```

### Removing a package
```bash
cd ~/dotfiles
stow -D package-name
```
## ⚠️ Warnings
- Back up your existing dotfiles before stowing!
- Some GUI application settings may need manual configuration (see docs)
- Review configurations before using, these are of course personalized to my workflow


---

**Current Machines:**
- 💻 MacBook Pro M4 (2025)
- 🖥️ Mac Studio M2 Max (2023)
```
