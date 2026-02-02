#!/usr/bin/env bash

###############################################################################
# Dotfiles Installation Script
# Author: Enrique Ramírez
# Description: Automated setup for new macOS computers
# Usage: ./install.sh [--dry-run]
#
# Quick Start (fresh Mac):
#   1. xcode-select --install
#   2. git clone https://github.com/enrique-ramirez/dotfiles ~/Projects/dotfiles
#   3. cd ~/Projects/dotfiles && ./install.sh
###############################################################################

set -e  # Exit on error

# Parse arguments
DRY_RUN=false
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --help)
            echo "Usage: ./install.sh [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --dry-run    Show what would be done without making changes"
            echo "  --help       Show this help message"
            echo ""
            echo "Bootstrap (fresh Mac):"
            echo "  1. Run: xcode-select --install"
            echo "  2. Wait for Command Line Tools to install"
            echo "  3. Clone this repo and run ./install.sh"
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
BOLD='\033[1m'
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

print_critical() {
    echo -e "\n${RED}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}║  ⚠️  CRITICAL: $1${NC}"
    echo -e "${RED}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}\n"
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

print_link() {
    echo -e "     ${CYAN}$1${NC}"
}

command_exists() {
    command -v "$1" &> /dev/null
}

# Check if a cask application is already installed (manually or via Homebrew)
# Returns 0 if installed, 1 if not
cask_app_installed() {
    local cask_name="$1"

    # Check if installed via Homebrew first
    if brew list --cask "$cask_name" &>/dev/null 2>&1; then
        return 0
    fi

    # Map cask names to actual .app names (only for non-standard cases)
    local app_name
    case "$cask_name" in
        "visual-studio-code") app_name="Visual Studio Code" ;;
        "google-chrome") app_name="Google Chrome" ;;
        "zen-browser") app_name="Zen Browser" ;;
        "1password") app_name="1Password" ;;
        "qlvideo") app_name="QuickLook Video" ;;
        "iina") app_name="IINA" ;;
        "the-unarchiver") app_name="The Unarchiver" ;;
        *)
            # Default: Convert dashes to spaces and capitalize each word
            app_name=$(echo "$cask_name" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
            ;;
    esac

    # Check both Applications folders
    [ -d "/Applications/${app_name}.app" ] || [ -d "$HOME/Applications/${app_name}.app" ]
}

# Add line to file if not already present
add_to_file_if_missing() {
    local file="$1"
    local search="$2"
    local content="$3"

    if ! grep -q "$search" "$file" 2>/dev/null; then
        echo "" >> "$file"
        echo "$content" >> "$file"
        return 0
    fi
    return 1
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

###############################################################################
# Info: 1Password will be installed automatically
###############################################################################

print_header "1Password Info"
echo -e "${CYAN}1Password will be installed automatically via Homebrew.${NC}"
echo -e "${CYAN}After installation, you'll need to:${NC}"
echo -e "  • Sign in to access your passwords and SSH keys"
echo -e "  • Retrieve license keys for other software"
echo -e "  • Configure browser extensions\n"

if [ -d "/Applications/1Password.app" ] || [ -d "$HOME/Applications/1Password.app" ]; then
    print_success "1Password is already installed"
else
    print_info "1Password will be installed shortly..."
fi

###############################################################################
# Install Command Line Tools for Xcode
###############################################################################

print_header "Command Line Tools"
if xcode-select -p &> /dev/null; then
    print_success "Already installed"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would run: xcode-select --install"
    else
        print_info "Installing Command Line Tools..."
        xcode-select --install

        # Wait for installation to complete (lazy user friendly!)
        print_info "Waiting for Command Line Tools installation..."
        print_info "A dialog will appear - click 'Install' and wait."
        echo ""

        # Poll until xcode-select -p succeeds
        until xcode-select -p &> /dev/null; do
            sleep 5
        done
        print_success "Command Line Tools installed!"
    fi
fi

###############################################################################
# Install Homebrew
###############################################################################

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

        if ! NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            print_error "Homebrew installation failed!"
            print_error "Check your internet connection and try again."
            exit 1
        fi

        # Add Homebrew to PATH for Apple Silicon Macs (for current session)
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        # Verify installation succeeded
        if ! command_exists brew; then
            print_error "Homebrew installed but 'brew' command not found!"
            print_error "Try restarting your terminal and running the script again."
            exit 1
        fi

        print_success "Homebrew installed"
    fi
fi

# Ensure brew is in PATH for this session (Apple Silicon)
if [[ $(uname -m) == "arm64" ]] && [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

###############################################################################
# Install packages from Brewfile
###############################################################################

print_header "Installing packages from Brewfile"

# Reminder about Mac App Store sign-in (needed for mas to install Spark, Xcode)
# Note: `mas account` is broken on macOS 12+ (Apple removed the private API)
# We just remind the user and let brew bundle handle any failures gracefully
if [ "$DRY_RUN" = false ]; then
    print_info "Mac App Store apps (Spark, Xcode) require being signed in."
    print_info "If not signed in, these will be skipped and can be installed later."
fi

if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    # Create a filtered Brewfile that excludes already-installed casks
    # This makes the script idempotent even for manually-installed apps
    FILTERED_BREWFILE="$DOTFILES_DIR/.Brewfile.filtered"
    SKIPPED_CASKS=()

    # Clear any existing filtered file
    > "$FILTERED_BREWFILE"

    print_info "Checking for already-installed applications..."

    # Process the Brewfile line by line, filtering out installed casks
    while IFS= read -r line || [ -n "$line" ]; do
        # Check if this is a cask line
        if [[ "$line" =~ ^cask[[:space:]]+\"([^\"]+)\" ]]; then
            cask_name="${BASH_REMATCH[1]}"
            if cask_app_installed "$cask_name"; then
                SKIPPED_CASKS+=("$cask_name")
                # Add as comment to show it was skipped
                echo "# SKIPPED (already installed): $line" >> "$FILTERED_BREWFILE"
            else
                echo "$line" >> "$FILTERED_BREWFILE"
            fi
        else
            # Keep all other lines (brew, mas, comments, etc.)
            echo "$line" >> "$FILTERED_BREWFILE"
        fi
    done < "$DOTFILES_DIR/Brewfile"

    # Report skipped casks
    if [ ${#SKIPPED_CASKS[@]} -gt 0 ]; then
        print_success "Skipping already-installed apps: ${SKIPPED_CASKS[*]}"
    fi

    if [ "$DRY_RUN" = true ]; then
        print_info "Packages that would be installed:"
        grep -E "^brew |^cask |^mas " "$FILTERED_BREWFILE" | while read line; do
            print_dry_run "$line"
        done
        rm -f "$FILTERED_BREWFILE"
    else
        print_info "Running brew bundle (this may take a while)..."
        cd "$DOTFILES_DIR"

        if ! brew bundle install --file="$FILTERED_BREWFILE"; then
            print_warning "Some packages failed to install"
            print_info "You can retry failed packages later with: brew bundle install"
            echo ""
            read -p "$(echo -e "${YELLOW}Continue with the rest of the setup? [Y/n]: ${NC}")" -n 1 -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                rm -f "$FILTERED_BREWFILE"
                print_error "Setup aborted. Fix brew issues and re-run ./install.sh"
                exit 1
            fi
        else
            print_success "All packages installed"
        fi

        # Clean up filtered Brewfile
        rm -f "$FILTERED_BREWFILE"
    fi
else
    print_warning "Brewfile not found at $DOTFILES_DIR/Brewfile"
fi

###############################################################################
# Accept Xcode License (if Xcode was installed)
###############################################################################

if [ "$DRY_RUN" = false ] && command_exists xcodebuild; then
    # Check if license is already accepted by running a simple xcodebuild command
    # If license isn't accepted, xcodebuild commands will fail
    if ! xcodebuild -version &>/dev/null; then
        print_header "Xcode License"
        print_info "Accepting Xcode license agreement..."
        sudo xcodebuild -license accept
        print_success "Xcode license accepted"
    fi
fi

###############################################################################
# QLVideo Setup (QuickLook support for webm, mkv, etc.)
###############################################################################

QLVIDEO_APP=""
if [ -d "/Applications/QuickLook Video.app" ]; then
    QLVIDEO_APP="/Applications/QuickLook Video.app"
elif [ -d "$HOME/Applications/QuickLook Video.app" ]; then
    QLVIDEO_APP="$HOME/Applications/QuickLook Video.app"
fi

if [ -n "$QLVIDEO_APP" ]; then
    print_header "QLVideo (QuickLook for Videos)"

    # Check if QLVideo plugin is already registered by looking for its plugin
    QLVIDEO_PLUGIN_REGISTERED=false
    if [ -d "$QLVIDEO_APP/Contents/Library/QuickLook" ] || \
       qlmanage -m 2>/dev/null | grep -q "QLVideo"; then
        QLVIDEO_PLUGIN_REGISTERED=true
    fi

    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would run QuickLook Video app to register plugin"
    else
        # Run the app once to register the QuickLook plugin with macOS
        # The app registers itself then can be quit
        print_info "Activating QLVideo QuickLook plugin..."
        open -a "QuickLook Video"
        sleep 2
        # The app should stay open - user can quit it manually or it runs in background
        print_success "QLVideo plugin activated"
        print_info "You can now preview webm, mkv, and other video files with QuickLook (Spacebar)"
        print_info "Note: You may need to restart Finder or log out/in for thumbnails to appear"
    fi
fi

###############################################################################
# Ghostty Setup (Early - for global hotkey ASAP)
###############################################################################

print_header "Ghostty Terminal Setup"

# Setup Ghostty config first
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
GHOSTTY_CONFIG_SRC="$DOTFILES_DIR/configs/ghostty.txt"
GHOSTTY_CONFIG_DST="$GHOSTTY_CONFIG_DIR/config"

if [ -f "$GHOSTTY_CONFIG_SRC" ]; then
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would setup Ghostty config"
    else
        # Check if already correctly symlinked
        if [ -L "$GHOSTTY_CONFIG_DST" ] && [ "$(readlink "$GHOSTTY_CONFIG_DST")" = "$GHOSTTY_CONFIG_SRC" ]; then
            print_success "Ghostty config already linked"
        else
            mkdir -p "$GHOSTTY_CONFIG_DIR"
            # Backup existing config only if it's a regular file
            if [ -f "$GHOSTTY_CONFIG_DST" ] && [ ! -L "$GHOSTTY_CONFIG_DST" ]; then
                mv "$GHOSTTY_CONFIG_DST" "$GHOSTTY_CONFIG_DST.backup.$(date +%Y%m%d_%H%M%S)"
                print_info "Backed up existing Ghostty config"
            fi
            # Remove existing symlink if pointing elsewhere
            [ -L "$GHOSTTY_CONFIG_DST" ] && rm "$GHOSTTY_CONFIG_DST"
            ln -sf "$GHOSTTY_CONFIG_SRC" "$GHOSTTY_CONFIG_DST"
            print_success "Ghostty config linked"
        fi
    fi
fi

# Check if Ghostty is installed and set it up for global hotkey
# Check both system-wide and user-specific Applications folders
GHOSTTY_APP=""
if [ -d "/Applications/Ghostty.app" ]; then
    GHOSTTY_APP="/Applications/Ghostty.app"
elif [ -d "$HOME/Applications/Ghostty.app" ]; then
    GHOSTTY_APP="$HOME/Applications/Ghostty.app"
fi

if [ -n "$GHOSTTY_APP" ] && [ "$DRY_RUN" = false ]; then
    print_info "Ghostty is installed!"
    echo ""
    echo -e "${YELLOW}${BOLD}⚡ Global Hotkey Setup (Ctrl+\`)${NC}"
    echo -e "For the global hotkey to work, Ghostty needs:"
    echo -e "  1. ${BOLD}Accessibility permissions${NC} - macOS will prompt when Ghostty opens"
    echo -e "  2. ${BOLD}Running in background${NC} - Configure 'Launch at Login' in Ghostty settings"
    echo ""

    # Add Ghostty to Login Items (only if not already added)
    if osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null | grep -q "Ghostty"; then
        print_success "Ghostty already in Login Items"
    else
        print_info "Adding Ghostty to Login Items..."
        osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$GHOSTTY_APP\", hidden:true}" 2>/dev/null && \
            print_success "Ghostty will launch at login (hidden)" || \
            print_warning "Could not add to Login Items - add manually in System Settings"
    fi

    echo ""
    read -p "$(echo -e "${YELLOW}Open Ghostty now to grant permissions? [Y/n]: ${NC}")" -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        print_info "Opening Ghostty..."
        open -a Ghostty
        echo ""
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║  When Ghostty opens, macOS will ask for Accessibility      ║${NC}"
        echo -e "${CYAN}║  permissions. Click 'Open System Settings' and enable it. ║${NC}"
        echo -e "${CYAN}║                                                            ║${NC}"
        echo -e "${CYAN}║  After that, try pressing ${BOLD}Ctrl+\`${NC}${CYAN} to toggle Ghostty!      ║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e "${YELLOW}Press Enter once you have granted permissions...${NC}")" -r
        print_success "Ghostty is ready with global hotkey!"
    fi
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would setup Ghostty global hotkey permissions"
    fi
fi

###############################################################################
# Install Oh My Zsh
###############################################################################

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

###############################################################################
# Configure Oh My Zsh plugins BEFORE sourcing
# This modifies the plugins line in ~/.zshrc directly
###############################################################################

print_header "Oh My Zsh Plugins"
if [ "$DRY_RUN" = true ]; then
    print_dry_run "Would configure Oh My Zsh plugins"
else
    # Define the plugins we want
    DESIRED_PLUGINS="git docker node npm nvm macos z"

    if [ -f "$ZSHRC_FILE" ]; then
        # Check if plugins line exists and update it
        if grep -q "^plugins=" "$ZSHRC_FILE"; then
            # Replace the plugins line with our desired plugins
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s/^plugins=.*/plugins=($DESIRED_PLUGINS)/" "$ZSHRC_FILE"
            else
                sed -i "s/^plugins=.*/plugins=($DESIRED_PLUGINS)/" "$ZSHRC_FILE"
            fi
            print_success "Plugins configured: $DESIRED_PLUGINS"
        else
            print_warning "plugins line not found in .zshrc"
        fi
    fi
fi

###############################################################################
# Add Homebrew to .zshrc (for Apple Silicon)
# MUST be done after Oh My Zsh install since it overwrites .zshrc
###############################################################################

print_header "Shell Configuration"
if [[ $(uname -m) == "arm64" ]]; then
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would add Homebrew to PATH in .zshrc"
    else
        if ! grep -q 'eval "\$(/opt/homebrew/bin/brew shellenv)"' "$ZSHRC_FILE" 2>/dev/null; then
            print_info "Adding Homebrew to PATH..."
            # Add at the beginning of the file, right after the comments
            {
                echo ''
                echo '# Homebrew (Apple Silicon)'
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
                echo ''
                cat "$ZSHRC_FILE"
            } > "$ZSHRC_FILE.tmp" && mv "$ZSHRC_FILE.tmp" "$ZSHRC_FILE"
            print_success "Homebrew PATH added to .zshrc"
        else
            print_success "Homebrew already in PATH"
        fi
    fi
fi

###############################################################################
# Install NVM
###############################################################################

print_header "NVM (Node Version Manager)"
if [ -d "$HOME/.nvm" ]; then
    print_success "Already installed"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would install NVM (latest version)"
        print_info "NVM installer would add configuration to ~/.zshrc"
    else
        print_info "Installing NVM (fetching latest version)..."
        # Fetch and install latest NVM version dynamically
        NVM_LATEST=$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
        if [ -z "$NVM_LATEST" ]; then
            NVM_LATEST="v0.40.3"  # Fallback if API fails
            print_warning "Could not fetch latest NVM version, using $NVM_LATEST"
        fi
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_LATEST}/install.sh" | bash
        print_success "NVM $NVM_LATEST installed"
        print_info "NVM has added its configuration to ~/.zshrc"
    fi
fi

# Source NVM for this session
if [ "$DRY_RUN" = false ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

###############################################################################
# Install Node.js LTS
###############################################################################

print_header "Node.js LTS"
# Source NVM if not already loaded
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if command_exists node; then
    print_success "Node $(node --version) already installed"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would install Node.js LTS via NVM"
    else
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
fi

###############################################################################
# Install pnpm
###############################################################################

print_header "pnpm"
if command_exists pnpm; then
    print_success "Already installed: $(pnpm --version)"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would install pnpm"
    else
        print_info "Installing pnpm..."
        curl -fsSL https://get.pnpm.io/install.sh | sh -
        print_success "pnpm installed"
        print_info "pnpm has added its configuration to ~/.zshrc"

        # Source pnpm for this session
        export PNPM_HOME="$HOME/Library/pnpm"
        export PATH="$PNPM_HOME:$PATH"
    fi
fi

###############################################################################
# Install Claude Code (Anthropic's AI coding assistant CLI)
###############################################################################

print_header "Claude Code"
if command_exists claude; then
    print_success "Already installed: $(claude --version 2>/dev/null || echo 'installed')"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would install Claude Code via npm"
    else
        if command_exists npm; then
            print_info "Installing Claude Code..."
            npm install -g @anthropic-ai/claude-code
            print_success "Claude Code installed"
            print_info "Run 'claude' to start using it"
        else
            print_warning "npm not found, skipping Claude Code installation"
            print_info "Install manually later with: npm install -g @anthropic-ai/claude-code"
        fi
    fi
fi

###############################################################################
# Install pyenv and Python
###############################################################################

print_header "pyenv (Python Version Manager)"

# Check if pyenv is installed (via Homebrew)
if command_exists pyenv; then
    print_success "pyenv already installed"
else
    print_warning "pyenv not found (should be installed via Brewfile)"
    print_info "Run 'brew install pyenv' manually if needed"
fi

# Configure shell integration for pyenv
if command_exists pyenv; then
    if grep -q 'PYENV_ROOT' "$ZSHRC_FILE" 2>/dev/null; then
        print_success "pyenv shell configuration already present"
    else
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "Would add pyenv configuration to .zshrc"
        else
            print_info "Adding pyenv configuration to $ZSHRC_FILE..."
            echo "" >> "$ZSHRC_FILE"
            echo "# pyenv (Python version manager)" >> "$ZSHRC_FILE"
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$ZSHRC_FILE"
            echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> "$ZSHRC_FILE"
            echo 'eval "$(pyenv init - zsh)"' >> "$ZSHRC_FILE"
            print_success "pyenv shell configuration added"
        fi
    fi

    # Initialize pyenv for this session
    if [ "$DRY_RUN" = false ]; then
        export PYENV_ROOT="$HOME/.pyenv"
        [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
    fi
fi

###############################################################################
# Install Latest Python via pyenv
###############################################################################

print_header "Python (via pyenv)"

if command_exists pyenv; then
    # Check if any Python version is installed via pyenv
    PYENV_VERSIONS=$(pyenv versions --bare 2>/dev/null | grep -v "system" || true)

    if [ -n "$PYENV_VERSIONS" ]; then
        CURRENT_PYTHON=$(pyenv version-name 2>/dev/null || echo "none")
        print_success "Python already installed via pyenv: $CURRENT_PYTHON"
        print_info "Installed versions:"
        pyenv versions --bare 2>/dev/null | while read version; do
            echo "    - $version"
        done
    else
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "Would install latest Python 3 via pyenv"
            print_dry_run "Would set it as global Python version"
        else
            print_info "Installing latest Python 3 (this may take a few minutes)..."

            # Install latest Python 3 (pyenv resolves '3' to latest 3.x.x)
            if pyenv install 3; then
                # Get the version that was just installed
                INSTALLED_VERSION=$(pyenv versions --bare 2>/dev/null | grep -v "system" | tail -1)
                print_success "Python $INSTALLED_VERSION installed"

                # Set as global Python
                print_info "Setting Python $INSTALLED_VERSION as global version..."
                pyenv global "$INSTALLED_VERSION"
                print_success "Python $INSTALLED_VERSION set as global"

                # Rehash to update shims
                pyenv rehash
            else
                print_warning "Python installation failed"
                print_info "You can install Python manually later with: pyenv install 3"
                print_info "Check build dependencies: https://github.com/pyenv/pyenv/wiki#suggested-build-environment"
            fi
        fi
    fi
else
    print_warning "pyenv not available, skipping Python installation"
    print_info "Install pyenv first, then run: pyenv install 3"
fi

###############################################################################
# Setup fzf shell integration (modern method)
###############################################################################

print_header "fzf Shell Integration"
if command_exists fzf; then
    if grep -q 'source <(fzf --zsh)' "$ZSHRC_FILE" 2>/dev/null || grep -q 'fzf --zsh' "$ZSHRC_FILE" 2>/dev/null; then
        print_success "Already configured"
    else
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "Would add fzf integration to .zshrc"
        else
            print_info "Adding fzf integration to $ZSHRC_FILE..."
            echo "" >> "$ZSHRC_FILE"
            echo "# fzf shell integration" >> "$ZSHRC_FILE"
            echo 'source <(fzf --zsh)' >> "$ZSHRC_FILE"
            print_success "fzf integration added"
        fi
    fi
else
    print_warning "fzf not installed, skipping integration"
fi

###############################################################################
# Google Cloud SDK installation (official installer)
# https://cloud.google.com/sdk/docs/install
###############################################################################

print_header "Google Cloud SDK"

GCLOUD_PATH="$HOME/google-cloud-sdk"

if [ -d "$GCLOUD_PATH" ]; then
    print_success "Already installed at $GCLOUD_PATH"
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would download and install Google Cloud SDK"
    else
        print_info "Downloading Google Cloud SDK..."

        # Determine the correct package for the architecture
        if [[ $(uname -m) == "arm64" ]]; then
            GCLOUD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-arm.tar.gz"
        else
            GCLOUD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-x86_64.tar.gz"
        fi

        # Download and extract to home directory
        cd "$HOME"
        if curl -fsSL "$GCLOUD_URL" -o google-cloud-sdk.tar.gz; then
            print_info "Extracting..."
            tar -xzf google-cloud-sdk.tar.gz
            rm google-cloud-sdk.tar.gz

            # Run the install script (non-interactive)
            print_info "Running Google Cloud SDK installer..."
            "$GCLOUD_PATH/install.sh" --quiet --path-update=false --command-completion=false

            print_success "Google Cloud SDK installed"
        else
            print_warning "Failed to download Google Cloud SDK"
            print_info "You can install it manually later from: https://cloud.google.com/sdk/docs/install"
        fi
        cd "$DOTFILES_DIR"
    fi
fi

# Configure shell integration
if [ -d "$GCLOUD_PATH" ]; then
    if grep -q "google-cloud-sdk" "$ZSHRC_FILE" 2>/dev/null; then
        print_success "Shell integration already configured"
    else
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "Would add Google Cloud SDK to .zshrc"
        else
            print_info "Adding Google Cloud SDK to $ZSHRC_FILE..."
            echo "" >> "$ZSHRC_FILE"
            echo "# Google Cloud SDK" >> "$ZSHRC_FILE"
            echo 'if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then source "$HOME/google-cloud-sdk/path.zsh.inc"; fi' >> "$ZSHRC_FILE"
            echo 'if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then source "$HOME/google-cloud-sdk/completion.zsh.inc"; fi' >> "$ZSHRC_FILE"
            print_success "Shell integration configured"
        fi
    fi
fi

###############################################################################
# Configure git diff-so-fancy
###############################################################################

print_header "Git diff-so-fancy Configuration"
if command_exists diff-so-fancy; then
    if git config --global core.pager 2>/dev/null | grep -q "diff-so-fancy"; then
        print_success "Already configured"
    else
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "Would configure git to use diff-so-fancy"
        else
            print_info "Configuring git to use diff-so-fancy..."
            git config --global core.pager "diff-so-fancy | less --tabs=4 -RF"
            git config --global interactive.diffFilter "diff-so-fancy --patch"
            print_success "diff-so-fancy configured"
        fi
    fi
else
    print_warning "diff-so-fancy not installed, skipping configuration"
fi

###############################################################################
# Git configuration
###############################################################################

print_header "Git Configuration"
GITCONFIG_SRC="$DOTFILES_DIR/configs/gitconfig"
GITCONFIG_DST="$HOME/.gitconfig"

if [ "$DRY_RUN" = true ]; then
    print_dry_run "Would symlink gitconfig from dotfiles"
else
    if [ -f "$GITCONFIG_SRC" ]; then
        # Check if already correctly symlinked
        if [ -L "$GITCONFIG_DST" ] && [ "$(readlink "$GITCONFIG_DST")" = "$GITCONFIG_SRC" ]; then
            print_success "Git config already linked"
        else
            # Backup existing gitconfig if it's a regular file (not a symlink)
            if [ -f "$GITCONFIG_DST" ] && [ ! -L "$GITCONFIG_DST" ]; then
                mv "$GITCONFIG_DST" "$GITCONFIG_DST.backup.$(date +%Y%m%d_%H%M%S)"
                print_info "Backed up existing .gitconfig"
            fi
            # Remove existing symlink if pointing elsewhere
            [ -L "$GITCONFIG_DST" ] && rm "$GITCONFIG_DST"
            ln -sf "$GITCONFIG_SRC" "$GITCONFIG_DST"
            print_success "Git configured (symlinked from dotfiles)"
        fi
    else
        print_warning "gitconfig not found at $GITCONFIG_SRC, configuring manually..."

        # Prompt for git identity if not already configured
        CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
        CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

        if [ -z "$CURRENT_NAME" ]; then
            read -p "$(echo -e "${YELLOW}Enter your name for git: ${NC}")" GIT_NAME
            git config --global user.name "$GIT_NAME"
        fi

        if [ -z "$CURRENT_EMAIL" ]; then
            read -p "$(echo -e "${YELLOW}Enter your email for git: ${NC}")" GIT_EMAIL
            git config --global user.email "$GIT_EMAIL"
        fi

        git config --global core.editor "cursor --wait"
        git config --global init.defaultBranch "main"
        print_success "Git configured"
    fi
fi

###############################################################################
# SSH Key Setup for GitHub
###############################################################################

print_header "SSH Key for GitHub"

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
SSH_KEY_PUB="$HOME/.ssh/id_ed25519.pub"

if [ -f "$SSH_KEY_PATH" ]; then
    print_success "SSH key already exists at $SSH_KEY_PATH"
    print_info "Your public key:"
    echo ""
    cat "$SSH_KEY_PUB"
    echo ""

    # Copy to clipboard
    cat "$SSH_KEY_PUB" | pbcopy
    print_success "Public key copied to clipboard! 📋"

    if [ "$DRY_RUN" = false ]; then
        echo ""
        read -p "$(echo -e "${YELLOW}Open GitHub to add this key? [Y/n]: ${NC}")" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            open "https://github.com/settings/ssh/new"
            print_info "Just paste (⌘V) and click 'Add SSH key'!"
        fi
    fi
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "Would generate SSH key at $SSH_KEY_PATH"
        print_dry_run "Would add SSH key to ssh-agent"
    else
        print_info "No SSH key found. Creating one now."
        echo ""

        read -p "$(echo -e "${YELLOW}Generate a new SSH key for GitHub? [Y/n]: ${NC}")" -n 1 -r
        echo

        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            # Create .ssh directory if it doesn't exist
            mkdir -p "$HOME/.ssh"
            chmod 700 "$HOME/.ssh"

            # Get email for SSH key (try git config first, then prompt)
            SSH_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
            if [ -z "$SSH_EMAIL" ]; then
                read -p "$(echo -e "${YELLOW}Enter your email for the SSH key: ${NC}")" SSH_EMAIL
                if [ -z "$SSH_EMAIL" ]; then
                    print_error "Email is required for SSH key generation"
                    SSH_EMAIL="user@example.com"
                    print_warning "Using placeholder: $SSH_EMAIL"
                fi
            else
                print_info "Using email from git config: $SSH_EMAIL"
            fi

            # Generate SSH key
            print_info "Generating SSH key..."
            ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY_PATH" -N ""

            # Start ssh-agent and add key
            eval "$(ssh-agent -s)" > /dev/null

            # Create or update SSH config
            SSH_CONFIG="$HOME/.ssh/config"
            if [ ! -f "$SSH_CONFIG" ] || ! grep -q "Host github.com" "$SSH_CONFIG"; then
                echo "" >> "$SSH_CONFIG"
                echo "Host github.com" >> "$SSH_CONFIG"
                echo "  AddKeysToAgent yes" >> "$SSH_CONFIG"
                echo "  UseKeychain yes" >> "$SSH_CONFIG"
                echo "  IdentityFile $SSH_KEY_PATH" >> "$SSH_CONFIG"
                chmod 600 "$SSH_CONFIG"
            fi

            # Add key to ssh-agent with keychain
            ssh-add --apple-use-keychain "$SSH_KEY_PATH" 2>/dev/null || ssh-add "$SSH_KEY_PATH"

            print_success "SSH key generated!"
            echo ""

            # Copy to clipboard automatically
            cat "$SSH_KEY_PUB" | pbcopy
            print_success "Public key copied to clipboard! 📋"
            echo ""
            echo -e "${CYAN}$(cat "$SSH_KEY_PUB")${NC}"
            echo ""

            # Open GitHub SSH settings
            print_info "Opening GitHub SSH settings..."
            open "https://github.com/settings/ssh/new"
            echo ""
            echo -e "${GREEN}Just paste (⌘V) and click 'Add SSH key'!${NC}"
            echo ""

            read -p "$(echo -e "${YELLOW}Press Enter once you have added the key to GitHub...${NC}")" -r
        else
            print_warning "Skipping SSH key generation"
            print_info "You can generate one later with: ssh-keygen -t ed25519 -C \"your@email.com\""
        fi
    fi
fi

###############################################################################
# Create Projects directory
###############################################################################

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

###############################################################################
# Setup config files
###############################################################################

print_header "Configuration Files"
print_info "Setting up configuration files..."

# Ghostty config (already set up earlier, just verify)
if [ -L "$HOME/.config/ghostty/config" ]; then
    print_success "Ghostty config already linked"
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
echo -e "\n${GREEN}Your Mac is now set up with development tools!${NC}\n"

###############################################################################
# Post-Installation Summary
###############################################################################

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              📦 Installed Applications                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${GREEN}All applications were installed automatically via Homebrew!${NC}\n"

echo -e "${CYAN}Installed:${NC}"
echo -e "   ✓ 1Password, Chrome, Zen Browser"
echo -e "   ✓ VS Code, Cursor, Ghostty, Docker"
echo -e "   ✓ Figma, Slack, ClickUp, Dropbox, Zoom"
echo -e "   ✓ Spotify, IINA (media player)"
echo -e "   ✓ QLVideo (QuickLook for webm, mkv, etc.)"
echo -e "   ✓ aria2 (download/torrent CLI)"
echo -e "   ✓ Claude Code (AI coding assistant)"
echo -e "   ✓ Spark, Xcode (from Mac App Store)"
echo -e "   ✓ Node.js (via NVM), Python (via pyenv)\n"

###############################################################################
# Next Steps
###############################################################################

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    📋 Next Steps                          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "  1. ${BOLD}Restart your terminal${NC} or run: ${CYAN}source ~/.zshrc${NC}"
echo -e "  2. ${BOLD}Add SSH key to GitHub${NC} (if not done): ${CYAN}https://github.com/settings/ssh/new${NC}"
echo -e "  3. ${BOLD}Configure Ghostty${NC}: Settings are already linked from dotfiles"
echo -e "  4. ${BOLD}Install optional apps${NC} from the links above\n"

# Optional OS update
echo ""
read -p "$(echo -e "${YELLOW}Do you want to update macOS now? [y/N]:${NC}")" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Checking for macOS updates..."
    softwareupdate -l
    echo ""
    read -p "$(echo -e "${YELLOW}Install all available updates? [y/N]:${NC}")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing updates (this may take a while)..."
        sudo softwareupdate -i -a
        print_success "Updates installed"
    fi
fi

echo -e "\n${GREEN}Enjoy your new setup!${NC} 🚀\n"
