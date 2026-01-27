#!/usr/bin/env bash

###############################################################################
# Backup Script
# Backs up current system configurations before running install
###############################################################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo -e "\n${YELLOW}Backing up existing configurations...${NC}\n"

mkdir -p "$BACKUP_DIR"

# Backup existing files
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$BACKUP_DIR/zshrc"
    echo -e "${GREEN}✓${NC} Backed up .zshrc"
fi

if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
    cp "$HOME/.gitconfig" "$BACKUP_DIR/gitconfig"
    echo -e "${GREEN}✓${NC} Backed up .gitconfig"
elif [ -L "$HOME/.gitconfig" ]; then
    echo -e "${CYAN}→${NC} Skipped .gitconfig (is a symlink)"
fi

if [ -f "$HOME/.config/ghostty/config" ]; then
    cp "$HOME/.config/ghostty/config" "$BACKUP_DIR/ghostty_config"
    echo -e "${GREEN}✓${NC} Backed up Ghostty config"
fi

# Create a list of installed Homebrew packages
if command -v brew &> /dev/null; then
    brew list --formula > "$BACKUP_DIR/brew_packages.txt"
    brew list --cask > "$BACKUP_DIR/brew_casks.txt"
    echo -e "${GREEN}✓${NC} Backed up Homebrew package list"
fi

echo -e "\n${GREEN}Backup complete!${NC}"
echo -e "${CYAN}Backup location:${NC} $BACKUP_DIR\n"

