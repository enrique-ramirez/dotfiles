#!/usr/bin/env bash

###############################################################################
# Uninstall Script
# Removes symlinks and optionally uninstalls packages
###############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${YELLOW}Dotfiles Uninstall Script${NC}\n"

# Remove symlinks (only the ones that actually point back into this repo, so
# re-running is safe and we never delete a config we didn't create)
echo -e "${YELLOW}Removing symlinks...${NC}"

remove_symlink() {
    local target="$1" expected="$2" label="$3"

    if [ ! -L "$target" ]; then
        echo -e "  ${YELLOW}→${NC} $label: not a symlink, leaving alone"
        return
    fi

    if [ "$(readlink "$target")" != "$expected" ]; then
        echo -e "  ${YELLOW}→${NC} $label: points elsewhere, leaving alone"
        return
    fi

    rm "$target"
    echo -e "  ${GREEN}✓${NC} Removed $label symlink"
}

remove_symlink "$HOME/.config/ghostty/config" "$DOTFILES_DIR/configs/ghostty.txt" "Ghostty config"
remove_symlink "$HOME/.gitconfig" "$DOTFILES_DIR/configs/gitconfig" "gitconfig"
remove_symlink "$HOME/.config/zed/settings.json" "$DOTFILES_DIR/configs/zed/settings.json" "Zed settings"

echo -e "\n${GREEN}Symlinks removed${NC}"

# Ask about removing packages NOT in the Brewfile
#
# NOTE: `brew bundle cleanup` uninstalls everything that is *not* listed in the
# Brewfile — it does NOT uninstall the Brewfile's own packages. That includes
# apps you installed by hand and preinstalled Mac App Store apps (Keynote,
# Pages, GarageBand...), so always show the plan and require a typed
# confirmation before passing --force.
echo ""
echo -e "${YELLOW}Optional cleanup${NC}"
echo -e "This removes Homebrew packages and App Store apps that are ${BOLD}not${NC} listed"
echo -e "in the Brewfile. It ${BOLD}keeps${NC} everything the Brewfile does list, so it does"
echo -e "${BOLD}not${NC} undo this repo's installs — it prunes everything else."
echo ""
echo -e "${RED}This will happily uninstall Keynote, Pages, GarageBand and any app you"
echo -e "installed by hand, if they are not in the Brewfile.${NC}"
echo ""

# cleanup exits 1 when it has something to remove, so don't let set -e trip
CLEANUP_PLAN=$(brew bundle cleanup --file="$DOTFILES_DIR/Brewfile" 2>/dev/null || true)

if echo "$CLEANUP_PLAN" | grep -q "^Would uninstall"; then
    echo -e "${YELLOW}Planned removals:${NC}"
    echo "$CLEANUP_PLAN" | grep -v "^Warning:"
    echo ""
    read -p "$(echo -e "${YELLOW}Type 'yes' to proceed, anything else to skip:${NC} ")" -r
    if [ "$REPLY" = "yes" ]; then
        brew bundle cleanup --force --file="$DOTFILES_DIR/Brewfile"
        echo -e "${GREEN}Packages removed${NC}"
    else
        echo -e "${GREEN}Skipped — Homebrew packages left untouched${NC}"
    fi
else
    echo -e "  ${GREEN}✓${NC} Nothing to clean up"
fi

echo -e "\n${GREEN}Uninstall complete!${NC}"

