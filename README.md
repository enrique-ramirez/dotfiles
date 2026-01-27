# Dotfiles

Automated setup for new macOS computers. Installs development tools, CLI utilities, and personal configurations.

## ⚠️ Before You Start

### 🔐 1Password is CRITICAL

**Install 1Password first!** It holds all your passwords and SSH keys. You'll need it to:

- Log into your accounts (GitHub, email, etc.)
- Access SSH keys for git authentication
- Retrieve license keys for other software

👉 **Download:** https://1password.com/downloads/mac/

## Quick Start (Fresh Mac)

On a **brand new Mac**, you need to bootstrap first since `git` isn't available:

```bash
# Step 1: Install Command Line Tools (required for git)
xcode-select --install

# Step 2: Wait for the installation dialog to complete...

# Step 3: Clone and run
git clone https://github.com/YOUR_USER/dotfiles ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install.sh
```

If you already have the repo (e.g., on a USB drive):

```bash
cd /path/to/dotfiles
./install.sh
```

## What This Does

### Development Tools
- **Homebrew** - Package manager
- **Oh My Zsh** - Enhanced shell with plugins (git, docker, node, npm, nvm, macos, z)
- **NVM** + Node.js LTS - Node version manager
- **pnpm** - Fast package manager
- **Git** - Version control with custom aliases

### CLI Utilities
- bat, fzf, tig, ripgrep, tree, jq, wget, diff-so-fancy

### Applications (via Homebrew)
- **Essential:** VSCode, Cursor, Ghostty
- **Database:** PostgreSQL
- **Cloud:** Google Cloud SDK

### Configurations
- Custom shell aliases and preferences
- Git configuration and aliases
- Ghostty terminal configuration
- SSH key generation for GitHub
- Tool integrations (fzf, gcloud)

## Usage

### Initial Setup
```bash
./install.sh          # Full installation
./install.sh --dry-run # Preview without changes
./install.sh --help   # Show help
```

### Keep Updated
```bash
./update.sh           # Update all packages and tools
./backup.sh           # Backup current configurations
```

### Customize

**Add packages:** Edit `Brewfile`, then run:
```bash
brew bundle install
```

**Change shell aliases:** Edit `configs/zshrc`

**Change git settings:** Edit `configs/gitconfig` or `install.sh`

## File Structure

```
dotfiles/
├── install.sh          # Main installation script
├── update.sh           # Update all packages
├── backup.sh           # Backup configurations
├── Brewfile            # Package definitions
├── configs/
│   ├── zshrc           # Shell configuration (aliases, env vars)
│   ├── gitconfig       # Git configuration
│   └── ghostty.txt     # Terminal configuration
└── docs/               # Additional documentation
```

## Optional Applications

These apps are **not auto-installed** to avoid potential failures on different systems. Download them manually as needed:

### 🔐 Critical - Install First
- **1Password:** https://1password.com/downloads/mac/

### 🌐 Browsers
- **Google Chrome:** https://www.google.com/chrome/
- **Zen Browser:** https://zen-browser.app/download/

### 💼 Productivity
- **Figma:** https://www.figma.com/downloads/
- **Slack:** https://slack.com/downloads/mac
- **ClickUp:** https://clickup.com/download
- **Dropbox:** https://www.dropbox.com/install
- **Spark:** Mac App Store

### 🎵 Entertainment
- **Spotify:** https://www.spotify.com/download/mac/

### 🛠️ Development (if needed)
- **Xcode:** Mac App Store

## SSH Key Setup

The install script will offer to generate an SSH key for GitHub. If you skip it, you can generate one later:

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your@email.com"

# Start ssh-agent
eval "$(ssh-agent -s)"

# Add key to agent with Keychain
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub | pbcopy
```

Then add it to GitHub: https://github.com/settings/ssh/new

## Ghostty Terminal (Global Hotkey)

Ghostty is configured with a **global hotkey** (`Ctrl+\``) to toggle visibility from anywhere. This is set up early in the installation process.

### Requirements for Global Hotkey

1. **Accessibility Permissions** - macOS will prompt when Ghostty first opens
   - Go to: `System Settings → Privacy & Security → Accessibility`
   - Enable Ghostty

2. **Ghostty Running** - The app must be running in the background
   - The installer adds Ghostty to Login Items automatically
   - Config includes `quit-after-last-window-closed = false` to keep it running

### Manual Setup (if needed)

```bash
# Add Ghostty to Login Items
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Ghostty.app", hidden:true}'

# Open System Settings for Accessibility
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
```

### Configuration

Ghostty config is at `~/.config/ghostty/config` (symlinked from dotfiles). Key settings:

- **Global hotkey:** `Ctrl+\`` toggles visibility
- **Transparency:** 80% opacity with blur
- **Window state:** Saves position and size
- **Background mode:** Stays running when windows closed

## Editor Settings

**VSCode:** Has built-in Settings Sync (already enabled if signed in)

**Cursor:** Import from VSCode → `Settings → Import from VS Code`

No need to manage editor settings in dotfiles - use built-in cloud sync.

## Troubleshooting

**Command Line Tools not installed:**
```bash
xcode-select --install
```

**Homebrew not in PATH (Apple Silicon):**
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Package installation failed:**
```bash
brew update
brew doctor
brew bundle install
```

**SSH key not working:**
```bash
# Check if ssh-agent is running
eval "$(ssh-agent -s)"

# Add your key
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Test GitHub connection
ssh -T git@github.com
```

**Oh My Zsh plugins not working:**
The plugins are configured directly in `~/.zshrc`. Check that the plugins line includes your desired plugins:
```bash
plugins=(git docker node npm nvm macos z)
```

## How It Works

- **Idempotent** - Safe to run multiple times, won't reinstall
- **Non-destructive** - Backs up existing configs before changes
- **Apple Silicon ready** - Properly handles /opt/homebrew path
- **Tool-managed configs** - NVM, pnpm, gcloud add their own configurations
- **Personal preferences** - Your aliases and settings in `configs/zshrc`
- **Optional apps** - Manual download to avoid installation failures

## Additional Documentation

See `docs/` folder for:
- Configuration philosophy
- Editor settings details
- Architecture diagrams
- Migration guides

---

**First time?** Run `./install.sh --dry-run` to see what will happen!
