#!/usr/bin/env bash

###############################################################################
# Update Script
# Updates all packages and tools to their latest versions
###############################################################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}===${NC} ${GREEN}$1${NC} ${BLUE}===${NC}"
}

print_success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "  ${CYAN}→${NC} $1"
}

echo -e "\n${YELLOW}Updating your Mac! 🔄${NC}\n"

# Update Homebrew
print_header "Updating Homebrew"
brew update
print_success "Homebrew updated"

# Upgrade packages
print_header "Upgrading Homebrew packages"
brew upgrade
print_success "All packages upgraded"

# Install any new packages from Brewfile
print_header "Checking Brewfile"
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DOTFILES_DIR"
brew bundle install --no-lock
print_success "Brewfile packages synced"

# Cleanup
print_header "Cleaning up"
brew cleanup
print_success "Cleanup complete"

# Update Oh My Zsh
print_header "Updating Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
    # Use the official OMZ update command (not git pull!)
    zsh -ic 'omz update --unattended' 2>/dev/null || \
        (cd "$HOME/.oh-my-zsh" && git pull --rebase --autostash)
    print_success "Oh My Zsh updated"
else
    print_info "Oh My Zsh not installed"
fi

# Update NVM
print_header "Checking NVM version"
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
    print_info "Current NVM version: $(nvm --version)"
    print_info "To update NVM, visit: https://github.com/nvm-sh/nvm#install--update-script"

    # Update Node.js to latest LTS
    print_info "Checking for Node.js LTS updates..."
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*
    print_success "Node.js updated to: $(node --version)"
else
    print_info "NVM not installed"
fi

# Update pnpm
print_header "Updating pnpm"
if command -v pnpm &> /dev/null; then
    # Use corepack if available (Node 16.10+), otherwise pnpm self-update
    if command -v corepack &> /dev/null; then
        corepack prepare pnpm@latest --activate 2>/dev/null || pnpm self-update
    else
        pnpm self-update 2>/dev/null || curl -fsSL https://get.pnpm.io/install.sh | sh -
    fi
    print_success "pnpm updated to: $(pnpm --version)"
else
    print_info "pnpm not installed"
fi

# Check for macOS updates
print_header "macOS Updates"
print_info "Checking for macOS updates..."
softwareupdate -l

echo ""
read -p "$(echo -e "${YELLOW}Install macOS updates now? [y/N]:${NC} ")" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Installing updates (this may take a while)..."
    sudo softwareupdate -i -a
    print_success "macOS updates installed"
fi

echo -e "\n${GREEN}All updates complete!${NC} 🎉\n"

