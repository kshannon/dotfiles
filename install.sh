#!/bin/bash

# Install GNU Stow
sudo apt-get update
sudo apt-get install -y stow

# Run stow to symlink dotfiles
# WARNING: USE THIS WITH CAUTION. IT IS INTENDED ONLY FOR DEV CONTAINERS
# THE TWO COMMANDS BELOW WILL OVERWRITE YOUR EXISTING DOTFILES/CONFIGS WITH THE ONES IN THIS REPO
stow --adopt .
git restore .
