# Dotfiles

Automated setup for new macOS computers. Installs development tools, CLI utilities, applications, and personal configurations.

## What This Does

### Development Tools
- **Homebrew** - Package manager
- **Oh My Zsh** - Enhanced shell
- **NVM** + Node.js LTS - Node version manager
- **pnpm** - Fast package manager
- **Git** - Version control with custom aliases

### CLI Utilities
- bat, fzf, tig, ripgrep, tree, jq, wget, diff-so-fancy

### Applications (via Homebrew)
- Google Chrome, VSCode, Cursor, Figma, Slack, Spotify
- 1Password, Dropbox, Ghostty
- PostgreSQL, Google Cloud SDK

### Configurations
- Custom shell aliases and preferences
- Git configuration and aliases
- Ghostty terminal configuration
- Tool integrations (fzf, gcloud)

## Quick Start

```bash
# Clone the repo
git clone <your-repo-url> ~/Projects/dotfiles
cd ~/Projects/dotfiles

# Preview what will happen (optional but recommended)
./install.sh --dry-run

# Run installation
./install.sh

# Reload shell
source ~/.zshrc
```

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

**Change git settings:** Edit `configs/gitconfig` or `install.sh` (lines 345-360)

## File Structure

```
dotfiles/
├── install.sh          # Main installation script
├── update.sh           # Update all packages
├── backup.sh           # Backup configurations
├── Brewfile            # Package definitions
├── configs/
│   ├── zshrc           # Shell configuration
│   ├── gitconfig       # Git configuration
│   └── ghostty.txt     # Terminal configuration
└── docs/               # Additional documentation
```

## Editor Settings

**VSCode:** Has built-in Settings Sync (already enabled if signed in)

**Cursor:** Import from VSCode → `Settings → Import from VS Code`

No need to manage editor settings in dotfiles - use built-in cloud sync.

## Manual Installations

Some apps aren't available via Homebrew:
- [Zen Browser](https://zen-browser.app/download/)
- [ClickUp](https://clickup.com/download)
- Spark (Mac App Store)
- Xcode (Mac App Store)

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

## How It Works

- **Idempotent** - Safe to run multiple times, won't reinstall
- **Non-destructive** - Backs up existing configs before changes
- **Tool-managed configs** - NVM, pnpm, gcloud add their own configurations
- **Personal preferences** - Your aliases and settings in `configs/zshrc`

## Additional Documentation

See `docs/` folder for:
- Configuration philosophy
- Editor settings details
- Architecture diagrams
- Migration guides

---

**First time?** Run `./install.sh --dry-run` to see what will happen!
