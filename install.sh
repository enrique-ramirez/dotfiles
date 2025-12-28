#!/usr/bin/env bash

###############################################################################
# Dotfiles Installation Script
# Author: Enrique Ramírez
# Description: Automated setup for new macOS computers
# Usage: ./install.sh [--dry-run]
###############################################################################

set -e  # Exit on error

# Parse arguments
DRY_RUN=false
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            echo "Usage: ./install.sh [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --dry-run    Show what would be done without making changes"
            echo "  --help       Show this help message"
            exit 0
            ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Dotfiles directory
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ZSHRC_FILE="$HOME/.zshrc"

###############################################################################
# Helper Functions
###############################################################################

print_header() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "\n${MAGENTA}[DRY RUN]${NC} ${BLUE}===${NC} ${GREEN}$1${NC} ${BLUE}===${NC}"
    else
        echo -e "\n${BLUE}===${NC} ${GREEN}$1${NC} ${BLUE}===${NC}"
    fi
}

print_success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "  ${CYAN}→${NC} $1"
}

print_warning() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "  ${RED}✗${NC} $1"
}

print_dry_run() {
    echo -e "  ${MAGENTA}[WOULD]${NC} $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

# Execute command or show what would be executed
execute() {
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "$*"
        return 0
    else
        eval "$*"
    fi
}

###############################################################################
# Installation Steps
###############################################################################

if [ "$DRY_RUN" = true ]; then
    echo -e "\n${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║                    DRY RUN MODE                            ║${NC}"
    echo -e "${MAGENTA}║  No changes will be made to your system                   ║${NC}"
    echo -e "${MAGENTA}║  This will show you what would happen                     ║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}\n"
fi

print_header "Setting up your Mac! 🚀"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS. Detected: $OSTYPE"
    exit 1
fi

# Install Command Line Tools for Xcode
print_header "Command Line Tools"
if xcode-select -p &> /dev/null; then
    print_success "Already installed"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would run: xcode-select --install"
    else
        print_info "Installing Command Line Tools..."
        xcode-select --install
        print_warning "Please complete the installation and run this script again"
        exit 0
    fi
fi

# Install Homebrew
print_header "Homebrew"
if command_exists brew; then
    print_success "Already installed"
    if [ "$DRY_RUN" = false ]; then
        print_info "Updating Homebrew..."
        brew update
    else
        print_dry_run "Would update Homebrew"
    fi
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would install Homebrew"
        print_dry_run "Would add to PATH for Apple Silicon if needed"
    else
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$ZSHRC_FILE"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        print_success "Homebrew installed"
    fi
fi

# Install packages from Brewfile
print_header "Installing packages from Brewfile"
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    if [ "$DRY_RUN" = true ]; then
        print_info "Packages that would be installed:"
        grep -E "^brew |^cask |^mas " "$DOTFILES_DIR/Brewfile" | while read line; do
            print_dry_run "$line"
        done
    else
        print_info "Running brew bundle..."
        cd "$DOTFILES_DIR"
        brew bundle install --no-lock
        print_success "All packages installed"
    fi
else
    print_warning "Brewfile not found at $DOTFILES_DIR/Brewfile"
fi

# Install Oh My Zsh
print_header "Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_success "Already installed"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would install Oh My Zsh"
    else
        print_info "Installing Oh My Zsh..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        print_success "Oh My Zsh installed"
    fi
fi

# Install NVM
print_header "NVM (Node Version Manager)"
if [ -d "$HOME/.nvm" ]; then
    print_success "Already installed"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would install NVM"
        print_info "NVM installer would add configuration to ~/.zshrc"
    else
        print_info "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        print_success "NVM installed"
        print_info "NVM has added its configuration to ~/.zshrc"
    fi
fi

# Source NVM for this session
if [ "$DRY_RUN" = false ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# Install Node.js LTS
print_header "Node.js LTS"
if command_exists node; then
    print_success "Node $(node --version) already installed"
else
    # Source NVM if not already loaded
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if command_exists nvm; then
        print_info "Installing Node.js LTS..."
        nvm install --lts
        nvm use --lts
        nvm alias default lts/*
        print_success "Node.js LTS installed"
    else
        print_warning "NVM not found, skipping Node.js installation"
    fi
fi

# Install pnpm
print_header "pnpm"
if command_exists pnpm; then
    print_success "Already installed: $(pnpm --version)"
else
    print_info "Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    print_success "pnpm installed"
    print_info "pnpm has added its configuration to ~/.zshrc"

    # Source pnpm for this session
    export PNPM_HOME="$HOME/Library/pnpm"
    export PATH="$PNPM_HOME:$PATH"
fi

# Setup fzf shell integration
print_header "fzf Shell Integration"
if command_exists fzf; then
    if grep -q "fzf --zsh" "$ZSHRC_FILE" 2>/dev/null; then
        print_success "Already configured"
    else
        print_info "Adding fzf integration to $ZSHRC_FILE..."
        echo "" >> "$ZSHRC_FILE"
        echo "# fzf shell integration" >> "$ZSHRC_FILE"
        echo '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' >> "$ZSHRC_FILE"
        print_success "fzf integration added"
    fi
else
    print_warning "fzf not installed, skipping integration"
fi

# Google Cloud SDK integration
print_header "Google Cloud SDK"
if [ -d "/opt/homebrew/share/google-cloud-sdk" ]; then
    if grep -q "google-cloud-sdk" "$ZSHRC_FILE" 2>/dev/null; then
        print_success "Already configured"
    else
        print_info "Adding Google Cloud SDK to $ZSHRC_FILE..."
        echo "" >> "$ZSHRC_FILE"
        echo "# Google Cloud SDK" >> "$ZSHRC_FILE"
        echo 'if [ -f "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc" ]; then' >> "$ZSHRC_FILE"
        echo '  source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"' >> "$ZSHRC_FILE"
        echo 'fi' >> "$ZSHRC_FILE"
        echo 'if [ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ]; then' >> "$ZSHRC_FILE"
        echo '  source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"' >> "$ZSHRC_FILE"
        echo 'fi' >> "$ZSHRC_FILE"
        print_success "Google Cloud SDK configured"
    fi
else
    print_info "Google Cloud SDK not installed (install via: brew install google-cloud-sdk)"
fi

# Configure git diff-so-fancy
print_header "Git diff-so-fancy Configuration"
if git config --global core.pager | grep -q "diff-so-fancy" 2>/dev/null; then
    print_success "Already configured"
else
    print_info "Configuring git to use diff-so-fancy..."
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RF"
    git config --global interactive.diffFilter "diff-so-fancy --patch"
    print_success "diff-so-fancy configured"
fi

# Git configuration
print_header "Git Configuration"
if [ "$DRY_RUN" = true ]; then
    print_dry_run "Would configure git user.name: Enrique Ramírez"
    print_dry_run "Would configure git user.email: hello@enrique-ramirez.com"
    print_dry_run "Would configure git editor: cursor --wait"
    print_dry_run "Would configure git default branch: main"
    print_dry_run "Would add git aliases (co, br, cm, st, df, lg, ll)"
else
    print_info "Configuring git..."
    git config --global user.name "Enrique Ramírez"
    git config --global user.email "hello@enrique-ramirez.com"
    git config --global core.editor "cursor --wait"
    git config --global init.defaultBranch "main"

    # Git aliases
    git config --global alias.co "checkout"
    git config --global alias.br "branch"
    git config --global alias.cm "commit"
    git config --global alias.st "status"
    git config --global alias.df "diff"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
    git config --global alias.ll "log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
    print_success "Git configured"
fi

# Create Projects directory
print_header "Projects Directory"
if [ -d "$HOME/Projects" ]; then
    print_success "Already exists"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would create ~/Projects directory"
    else
        print_info "Creating ~/Projects..."
        mkdir -p "$HOME/Projects"
        print_success "Projects directory created"
    fi
fi

# Setup config files
print_header "Configuration Files"
print_info "Setting up configuration files..."

# Ghostty config
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
if [ -f "$DOTFILES_DIR/configs/ghostty.txt" ]; then
    if [ "$DRY_RUN" = true ]; then
        if [ -f "$GHOSTTY_CONFIG_DIR/config" ] || [ -L "$GHOSTTY_CONFIG_DIR/config" ]; then
            print_dry_run "Would backup existing Ghostty config"
        fi
        print_dry_run "Would symlink $DOTFILES_DIR/configs/ghostty.txt → ~/.config/ghostty/config"
    else
        mkdir -p "$GHOSTTY_CONFIG_DIR"
        if [ -f "$GHOSTTY_CONFIG_DIR/config" ] || [ -L "$GHOSTTY_CONFIG_DIR/config" ]; then
            print_warning "Ghostty config already exists, backing up..."
            mv "$GHOSTTY_CONFIG_DIR/config" "$GHOSTTY_CONFIG_DIR/config.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        ln -s "$DOTFILES_DIR/configs/ghostty.txt" "$GHOSTTY_CONFIG_DIR/config"
        print_success "Ghostty config linked"
    fi
else
    print_warning "Ghostty config not found at $DOTFILES_DIR/configs/ghostty.txt"
fi

# Source custom aliases and preferences from dotfiles
if [ "$DRY_RUN" = true ]; then
    print_dry_run "Would add source line to ~/.zshrc for custom config"
else
    print_info "Adding custom configuration to $ZSHRC_FILE..."
    CUSTOM_CONFIG_SOURCE="# Source custom dotfiles configuration
if [ -f \"$DOTFILES_DIR/configs/zshrc\" ]; then
  source \"$DOTFILES_DIR/configs/zshrc\"
fi"

    if grep -q "Source custom dotfiles configuration" "$ZSHRC_FILE" 2>/dev/null; then
        print_success "Custom config already sourced"
    else
        echo "" >> "$ZSHRC_FILE"
        echo "$CUSTOM_CONFIG_SOURCE" >> "$ZSHRC_FILE"
        print_success "Custom configuration added"
    fi
fi

###############################################################################
# Completion
###############################################################################

if [ "$DRY_RUN" = true ]; then
    print_header "Dry Run Complete! 📋"
    echo -e "\n${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║                 DRY RUN SUMMARY                            ║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}\n"

    echo -e "${GREEN}✓${NC} No changes were made to your system"
    echo -e "${GREEN}✓${NC} Above shows what would happen during installation"
    echo -e "${GREEN}✓${NC} Review the output to understand what will be installed\n"

    echo -e "${CYAN}To run the actual installation:${NC}"
    echo -e "  ${YELLOW}./install.sh${NC}\n"

    echo -e "${CYAN}Tip:${NC} You can redirect output to a file for review:"
    echo -e "  ${YELLOW}./install.sh --dry-run > dry-run-output.txt${NC}\n"

    exit 0
fi

print_header "Installation Complete! 🎉"
echo -e "\n${GREEN}Your Mac is now set up!${NC}\n"

print_info "Next steps:"
echo -e "  1. Restart your terminal or run: ${CYAN}source ~/.zshrc${NC}"
echo -e "  2. Install Node.js LTS: ${CYAN}nvm install --lts${NC}"
echo -e "  3. Check manual installations needed:"
echo -e "     - Zen Browser: https://zen-browser.app/download/"
echo -e "     - ClickUp: https://clickup.com/download"
echo -e "     - Spark: Mac App Store"
echo -e "     - Xcode: Mac App Store (if needed)"

# Optional OS update
echo ""
read -p "$(echo -e ${YELLOW}Do you want to update macOS now? [y/N]:${NC} )" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Checking for macOS updates..."
    softwareupdate -l
    echo ""
    read -p "$(echo -e ${YELLOW}Install all available updates? [y/N]:${NC} )" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing updates (this may take a while)..."
        sudo softwareupdate -i -a
        print_success "Updates installed"
    fi
fi

echo -e "\n${GREEN}Enjoy your new setup!${NC} 🚀\n"

