#!/usr/bin/env bash

###############################################################################
# Uninstall Script
# Removes symlinks and optionally uninstalls packages
###############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${YELLOW}Dotfiles Uninstall Script${NC}\n"

# Remove symlinks
echo -e "${YELLOW}Removing symlinks...${NC}"

if [ -L "$HOME/.config/ghostty/config" ]; then
    rm "$HOME/.config/ghostty/config"
    echo -e "  ${GREEN}✓${NC} Removed Ghostty config symlink"
fi

if [ -L "$HOME/.gitconfig" ]; then
    rm "$HOME/.gitconfig"
    echo -e "  ${GREEN}✓${NC} Removed gitconfig symlink"
fi

echo -e "\n${GREEN}Symlinks removed${NC}"

# Ask about uninstalling packages
echo ""
read -p "$(echo -e "${YELLOW}Do you want to uninstall Homebrew packages? [y/N]:${NC} ")" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Uninstalling Homebrew packages...${NC}"
    brew bundle cleanup --force --file=Brewfile
    echo -e "${GREEN}Packages uninstalled${NC}"
fi

echo -e "\n${GREEN}Uninstall complete!${NC}"

