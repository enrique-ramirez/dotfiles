# Dotfiles

Automated setup for new macOS computers. Installs development tools, CLI utilities, applications, and personal configurations.

## Quick Start (Fresh Mac)

On a **brand new Mac**, you need Command Line Tools before you can clone:

```bash
# Step 1: Install Command Line Tools (required for git)
xcode-select --install

# Step 2: Wait for the installation dialog to complete...

# Step 3: Clone and run
git clone https://github.com/enrique-ramirez/dotfiles ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install.sh
```

**Alternative:** Copy the repo to a USB drive and run directly:

```bash
cd /path/to/dotfiles
./install.sh
```

> 💡 **Tip:** Run `./install.sh --dry-run` first to preview what will happen!

## What Gets Installed

### 🛠️ CLI Tools (via Homebrew)

| Tool | Description |
|------|-------------|
| `bat` | Better `cat` with syntax highlighting |
| `fzf` | Fuzzy finder for files and history |
| `ripgrep` | Better `grep` (aliased as `grep`) |
| `fd` | Better `find` (aliased as `find`) |
| `eza` | Modern `ls` replacement with icons |
| `tree` | Directory structure viewer |
| `jq` | JSON processor |
| `tig` | Text-mode git interface |
| `tldr` | Simplified man pages |
| `diff-so-fancy` | Better git diffs |
| `wget` | Download utility |

### 💻 Applications (via Homebrew Casks)

**Development:**
- Zed, Ghostty, OrbStack (Docker)

**Security:**
- 1Password

**Browsers:**
- Google Chrome, Zen Browser

**Productivity:**
- Figma, Slack, ClickUp, Dropbox, Zoom

**Entertainment:**
- Spotify

**Mac App Store** (requires sign-in):
- Spark (email), Xcode

### ⚙️ Development Environment

- **Homebrew** — Package manager
- **Oh My Zsh** — Enhanced shell with plugins (git, docker, node, npm, nvm, macos, z)
- **NVM** — Node version manager (installs latest LTS)
- **pnpm** — Fast package manager
- **Google Cloud SDK** — GCP CLI tools

### 📝 Configurations

- Git config with aliases and diff-so-fancy
- Ghostty terminal with global hotkey (`Ctrl+\``)
- Shell aliases (see `configs/zshrc`)
- SSH key generation for GitHub
- fzf and gcloud shell integrations

## Usage

### Scripts

```bash
./install.sh          # Full installation
./install.sh --dry-run # Preview without making changes
./install.sh --help   # Show help

./update.sh           # Update all packages and tools
./backup.sh           # Backup current configurations
./uninstall.sh        # Remove symlinks and optionally packages
```

### Customization

**Add/remove packages:** Edit `Brewfile`, then run:
```bash
brew bundle install
```

**Change shell aliases:** Edit `configs/zshrc`

**Change git settings:** Edit `configs/gitconfig`

**Change terminal settings:** Edit `configs/ghostty.txt`

## File Structure

```
dotfiles/
├── install.sh          # Main installation script
├── update.sh           # Update all packages
├── backup.sh           # Backup configurations
├── uninstall.sh        # Uninstall script
├── Brewfile            # Homebrew packages
└── configs/
    ├── zshrc           # Shell aliases and env vars
    ├── gitconfig       # Git configuration
    └── ghostty.txt     # Ghostty terminal config
```

## SSH Key Setup

The install script offers to generate an SSH key for GitHub. If you skip it:

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your@email.com"

# Start ssh-agent
eval "$(ssh-agent -s)"

# Add key to agent with Keychain
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Copy public key to clipboard
cat ~/.ssh/id_ed25519.pub | pbcopy
```

Then add it at: https://github.com/settings/ssh/new

## Ghostty Terminal

Ghostty is configured with a **global hotkey** (`Ctrl+\``) to toggle visibility from anywhere.

### Requirements

1. **Accessibility Permissions** — macOS will prompt when Ghostty first opens
   - System Settings → Privacy & Security → Accessibility → Enable Ghostty

2. **Running in Background** — The installer adds Ghostty to Login Items automatically

### Configuration

Config is at `~/.config/ghostty/config` (symlinked from `configs/ghostty.txt`):

- **Global hotkey:** `Ctrl+\`` toggles visibility
- **Transparency:** 80% opacity with blur
- **Background mode:** Stays running when windows closed

### Manual Setup (if needed)

```bash
# Add Ghostty to Login Items
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Ghostty.app", hidden:true}'

# Open Accessibility settings
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
```

## Editor Settings

**Zed** settings are managed in this repo at `configs/zed/settings.json` and symlinked to `~/.config/zed/settings.json` by `install.sh`, so they stay in sync across machines via git.

## Supply-Chain Cooldown

Both `install.sh` and `update.sh` refuse to install or upgrade a Homebrew package whose current version landed in the tap less than **48 hours** ago (compromised releases are usually detected and pulled well within 24h). Too-fresh packages are *deferred*: upgrades keep the currently installed version and installs wait — both retry automatically on the next run.

- Implemented in `lib/cooldown.sh`, which checks the last commit date of each formula/cask file in the Homebrew tap via the GitHub API.
- Homebrew taps only carry one version per package, so deferring (rather than falling back to an older version, as npm can) is the only option.
- Override the window with `COOLDOWN_HOURS=24 ./update.sh`; set `GITHUB_TOKEN` to avoid GitHub API rate limits (60 req/h anonymous).
- If the age of a package can't be determined (API failure, rate limit), it is deferred — the check fails safe.

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
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh -T git@github.com
```

**Oh My Zsh plugins not loading:**
Check `~/.zshrc` includes:
```bash
plugins=(git docker node npm nvm macos z)
```

## How It Works

- **Idempotent** — Safe to run multiple times
- **Non-destructive** — Backs up existing configs before overwriting
- **Apple Silicon ready** — Handles `/opt/homebrew` path correctly
- **Graceful failures** — Continues if some packages fail (e.g., App Store apps)

---

**First time?** Run `./install.sh --dry-run` to preview!
