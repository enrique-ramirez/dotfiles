#!/usr/bin/env bash

###############################################################################
# Update Script
# Updates all packages and tools to their latest versions
# Usage: ./update.sh [--skip-macos]
###############################################################################

set -e

# Parse arguments
SKIP_MACOS=false
for arg in "$@"; do
    case $arg in
        --skip-macos)
            SKIP_MACOS=true
            ;;
        --help)
            echo "Usage: ./update.sh [--skip-macos]"
            echo ""
            echo "Options:"
            echo "  --skip-macos    Skip macOS system updates"
            echo "  --help          Show this help message"
            exit 0
            ;;
    esac
done

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

print_warning() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

command_exists() {
    command -v "$1" &> /dev/null
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
brew bundle install
print_success "Brewfile packages synced"

# Cleanup
print_header "Cleaning up"
brew cleanup
print_success "Cleanup complete"

# Update Oh My Zsh
print_header "Updating Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
    zsh -ic 'omz update --unattended' 2>/dev/null && \
        print_success "Oh My Zsh updated" || \
        print_warning "Oh My Zsh update failed (try manually: omz update)"
else
    print_info "Oh My Zsh not installed"
fi

# Update NVM
print_header "Updating NVM"
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
    CURRENT_NVM=$(nvm --version)
    print_info "Current NVM version: v$CURRENT_NVM"

    # Fetch latest NVM version from GitHub
    LATEST_NVM=$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')

    if [ -n "$LATEST_NVM" ] && [ "$CURRENT_NVM" != "$LATEST_NVM" ]; then
        print_info "Latest NVM version: v$LATEST_NVM"
        read -p "$(echo -e "  ${YELLOW}Update NVM to v$LATEST_NVM? [Y/n]:${NC} ")" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            print_info "Updating NVM..."
            curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${LATEST_NVM}/install.sh" | bash
            # Reload NVM
            \. "$NVM_DIR/nvm.sh"
            print_success "NVM updated to v$(nvm --version)"
        fi
    else
        print_success "NVM is up to date"
    fi

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
if command_exists pnpm; then
    if pnpm self-update &>/dev/null; then
        print_success "pnpm updated to: $(pnpm --version)"
    else
        print_info "self-update failed, reinstalling..."
        curl -fsSL https://get.pnpm.io/install.sh | sh -
        print_success "pnpm updated to: $(pnpm --version)"
    fi
else
    print_info "pnpm not installed"
fi

# Update Claude Code
print_header "Updating Claude Code"
if command_exists claude; then
    print_info "Updating Claude Code..."
    npm update -g @anthropic-ai/claude-code && \
        print_success "Claude Code updated" || \
        print_warning "Claude Code update failed"
else
    print_info "Claude Code not installed"
fi

# Update pyenv Python
print_header "Checking Python (pyenv)"
if command_exists pyenv; then
    # Initialize pyenv for this session
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"

    CURRENT_PYTHON=$(pyenv version-name 2>/dev/null || echo "none")
    print_info "Current Python: $CURRENT_PYTHON"

    # Check for newer Python 3.x
    LATEST_PYTHON=$(pyenv install --list 2>/dev/null | grep -E "^\s*3\.[0-9]+\.[0-9]+$" | tail -1 | tr -d ' ')
    if [ -n "$LATEST_PYTHON" ] && [ "$CURRENT_PYTHON" != "$LATEST_PYTHON" ]; then
        print_info "Latest available: $LATEST_PYTHON"
        read -p "$(echo -e "  ${YELLOW}Install Python $LATEST_PYTHON? [y/N]:${NC} ")" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            pyenv install "$LATEST_PYTHON"
            pyenv global "$LATEST_PYTHON"
            pyenv rehash
            print_success "Python updated to $LATEST_PYTHON"
        fi
    else
        print_success "Python is up to date"
    fi
else
    print_info "pyenv not installed"
fi

# Update Google Cloud SDK
print_header "Updating Google Cloud SDK"
GCLOUD_PATH="$HOME/google-cloud-sdk"
if [ -d "$GCLOUD_PATH" ]; then
    print_info "Updating Google Cloud SDK components..."
    "$GCLOUD_PATH/bin/gcloud" components update --quiet && \
        print_success "Google Cloud SDK updated" || \
        print_warning "Google Cloud SDK update failed"
else
    print_info "Google Cloud SDK not installed"
fi

# Update Cloud SQL Proxy
print_header "Updating Cloud SQL Proxy"
if command_exists cloud-sql-proxy; then
    CURRENT_VERSION=$(cloud-sql-proxy --version 2>&1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    print_info "Current version: $CURRENT_VERSION"

    # Fetch latest version from GitHub
    LATEST_VERSION=$(curl -fsSL https://api.github.com/repos/GoogleCloudPlatform/cloud-sql-proxy/releases/latest 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"(v[^"]+)".*/\1/')

    if [ -n "$LATEST_VERSION" ] && [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
        print_info "Latest version: $LATEST_VERSION"
        read -p "$(echo -e "  ${YELLOW}Update Cloud SQL Proxy to $LATEST_VERSION? [Y/n]:${NC} ")" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            print_info "Downloading Cloud SQL Proxy $LATEST_VERSION..."

            # Determine the correct binary for the architecture
            if [[ $(uname -m) == "arm64" ]]; then
                PROXY_URL="https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/${LATEST_VERSION}/cloud-sql-proxy.darwin.arm64"
            else
                PROXY_URL="https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/${LATEST_VERSION}/cloud-sql-proxy.darwin.amd64"
            fi

            TEMP_PROXY="/tmp/cloud-sql-proxy"
            if curl -fsSL "$PROXY_URL" -o "$TEMP_PROXY"; then
                chmod +x "$TEMP_PROXY"
                print_info "Installing to /usr/local/bin (requires sudo)..."
                sudo mv "$TEMP_PROXY" /usr/local/bin/cloud-sql-proxy
                print_success "Cloud SQL Proxy updated to $(cloud-sql-proxy --version 2>&1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
            else
                print_warning "Failed to download Cloud SQL Proxy"
            fi
        fi
    else
        print_success "Cloud SQL Proxy is up to date"
    fi
else
    print_info "Cloud SQL Proxy not installed (run ./install.sh to install)"
fi

# Check for macOS updates
if [ "$SKIP_MACOS" = false ]; then
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
else
    print_info "Skipping macOS updates (--skip-macos flag)"
fi

echo -e "\n${GREEN}All updates complete!${NC} 🎉\n"

