# Dotfiles

This repository contains my dotfiles, which are configuration files for various programs. To easily manage these dotfiles, I use GNU Stow.

## Installation

To install GNU Stow, follow these steps:

1. Open a terminal.
2. Run the following command to install GNU Stow:

    ```bash
    # For Debian-based systems (e.g., Ubuntu)
    sudo apt-get install stow

    # For Red Hat-based systems (e.g., Fedora)
    sudo dnf install stow

    # For macOS (using Homebrew)
    brew install stow
    ```

## Usage

Once GNU Stow is installed, you can symlink the dotfiles to your home directory using the following command:

```bash
cd ~/dotfiles
stow .
```

This will create symlinks for all the dotfiles in the repository. Thus, you can easily version control your dotfiles using Git. Credit goes to [Dreams of Anatomy](https://youtu.be/y6XCebnB9gs?si=kP2rrHu6xishHkkF)