# Testing Your Dotfiles Setup

## 🧪 Safe Testing with Dry Run

The install script includes a **dry-run mode** that shows you exactly what would happen without making any changes to your system.

### How to Use Dry Run

```bash
cd ~/Projects/dotfiles
./install.sh --dry-run
```

### What Dry Run Shows You

The dry-run mode will:
- ✅ Check what's already installed
- ✅ Show what would be installed
- ✅ Display all Brewfile packages that would be added
- ✅ Show configuration changes that would be made
- ✅ Preview git configuration
- ✅ Show symlinks that would be created
- ❌ **Make NO changes to your system**

### Example Output

```
╔════════════════════════════════════════════════════════════╗
║                    DRY RUN MODE                            ║
║  No changes will be made to your system                   ║
║  This will show you what would happen                     ║
╚════════════════════════════════════════════════════════════╝

[DRY RUN] === Homebrew ===
  ✓ Already installed
  [WOULD] Would update Homebrew

[DRY RUN] === Installing packages from Brewfile ===
  → Packages that would be installed:
  [WOULD] brew "git"
  [WOULD] brew "bat"
  [WOULD] cask "google-chrome"
  [WOULD] cask "cursor"
  ...

[DRY RUN] === Git Configuration ===
  [WOULD] Would configure git user.name: Enrique Ramírez
  [WOULD] Would configure git editor: cursor --wait
  ...
```

## 📋 Testing Workflow

### Step 1: Dry Run First (Recommended!)

```bash
# See what would happen
./install.sh --dry-run

# Save output for review
./install.sh --dry-run > dry-run-output.txt
```

**Review the output** to understand:
- What's already installed (✓ Already installed)
- What would be installed ([WOULD] ...)
- What changes would be made
- If there are any warnings (⚠)

### Step 2: Test on Current Machine (Safe)

Your current machine already has most things installed, so running the actual install is safe:

```bash
# The script is idempotent - safe to run multiple times
./install.sh
```

**Why this is safe:**
- Script checks before installing
- Skips what's already there
- Backs up existing configs
- Won't duplicate configurations

### Step 3: Verify Installation

After running (or during dry-run), check the output for:

```bash
# Success indicators
✓ Already installed
✓ Package installed
✓ Config linked

# What would happen (dry-run only)
[WOULD] Would install X
[WOULD] Would configure Y

# Warnings (important!)
⚠ Config already exists, backing up...
⚠ Package not found
```

## 🔍 What Gets Checked

### System Prerequisites
- [x] macOS operating system
- [x] Command Line Tools for Xcode
- [x] Homebrew

### Core Tools
- [x] Oh My Zsh
- [x] NVM & Node.js LTS
- [x] pnpm
- [x] Git configuration

### Packages (from Brewfile)
- [x] CLI tools (bat, fzf, tig, ripgrep, etc.)
- [x] GUI applications (Chrome, VSCode, Cursor, etc.)
- [x] Databases (PostgreSQL)
- [x] Cloud tools (Google Cloud SDK)

### Configurations
- [x] Ghostty terminal config symlink
- [x] Custom zshrc sourced
- [x] Git aliases and settings
- [x] fzf shell integration
- [x] Google Cloud SDK integration

## 🛡️ Safety Features

### 1. **Idempotent**
```bash
# Safe to run multiple times
./install.sh
./install.sh  # Won't duplicate anything
./install.sh  # Still safe!
```

### 2. **Checks Before Installing**
```bash
if command_exists brew; then
    print_success "Already installed"
else
    print_info "Installing..."
fi
```

### 3. **Backups Existing Configs**
```bash
# If Ghostty config exists
mv ~/.config/ghostty/config ~/.config/ghostty/config.backup.20250128_120000
```

### 4. **Non-Destructive**
- Won't delete existing files
- Won't overwrite without backing up
- Won't break existing setup

## 📊 Testing Scenarios

### Scenario 1: Fresh Mac
```bash
# Clone dotfiles
git clone <repo-url> ~/Projects/dotfiles
cd ~/Projects/dotfiles

# Dry run first
./install.sh --dry-run
# Review output - should show [WOULD] install for most things

# Run installation
./install.sh
# Everything gets installed
```

### Scenario 2: Existing Setup (Your Current Mac)
```bash
cd ~/Projects/dotfiles

# Dry run first
./install.sh --dry-run
# Should show "Already installed" for most things

# Run installation
./install.sh
# Only adds what's missing, updates configs
```

### Scenario 3: Testing Changes
```bash
# Edit Brewfile - add new package
echo 'brew "htop"' >> Brewfile

# Dry run to see what would change
./install.sh --dry-run
# Should show [WOULD] brew "htop"

# Run to install new package
./install.sh
# Installs only the new package
```

## ✅ Verification Checklist

After installation (real or dry-run), verify:

### CLI Tools Installed
```bash
brew --version          # Homebrew
git --version          # Git
bat --version          # bat
fzf --version          # fzf
tig --version          # tig
rg --version           # ripgrep
nvm --version          # NVM
node --version         # Node.js
pnpm --version         # pnpm
```

### Git Configuration
```bash
git config --global user.name      # Should show your name
git config --global user.email     # Should show your email
git config --global core.editor    # Should show cursor
git config --global --get-regexp alias  # Should show aliases
```

### Shell Aliases Work
```bash
ll                     # Should show detailed listing
cat README.md          # Should use bat (syntax highlighting)
gst                    # Should run git status
```

### Configs Linked
```bash
ls -la ~/.config/ghostty/config  # Should be symlink to dotfiles
grep "custom dotfiles" ~/.zshrc  # Should find source line
```

## 🐛 Troubleshooting Tests

### Dry Run Shows Errors?

```bash
# Error: Command Line Tools not installed
[WOULD] Would run: xcode-select --install
# Solution: Install before running actual install

# Error: Brewfile not found
⚠ Brewfile not found at ~/Projects/dotfiles/Brewfile
# Solution: Check you're in the correct directory
```

### Dry Run Shows Unexpected Installations?

```bash
# If it would install things you already have:
[WOULD] Would install NVM
# But you have NVM installed

# Reason: Script checks specific locations
# Solution: Check installation paths match expected
```

### Want to Test Individual Sections?

You can manually run specific parts:

```bash
# Test Brewfile without installing
brew bundle check

# List what would be installed
brew bundle list

# Test if packages are available
brew info <package-name>

# Check if config exists
ls -la ~/.config/ghostty/config
```

## 🎯 Recommended Testing Workflow

### For Current Mac (What You Should Do)

```bash
1. cd ~/Projects/dotfiles
2. ./install.sh --dry-run          # Preview
3. ./install.sh --dry-run > test.txt  # Save for review
4. cat test.txt                     # Review carefully
5. ./install.sh                     # Run if happy with preview
```

### For Fresh Mac (Future)

```bash
1. Clone repo
2. cd ~/Projects/dotfiles
3. ./install.sh --dry-run          # See what happens
4. ./install.sh                     # Full installation
5. source ~/.zshrc                  # Reload shell
```

## 📈 Advanced Testing

### Save Dry Run Output
```bash
# Create a test log
./install.sh --dry-run | tee dry-run-$(date +%Y%m%d).log

# Compare different runs
diff dry-run-20250128.log dry-run-20250129.log
```

### Test Specific Scenarios
```bash
# Test with existing Oh My Zsh
[ -d ~/.oh-my-zsh ] && echo "OMZ exists"

# Test with existing NVM
[ -d ~/.nvm ] && echo "NVM exists"

# Test Brewfile syntax
brew bundle check --file=Brewfile
```

### Validate Brewfile
```bash
# Check if all packages exist in Homebrew
brew bundle check

# List all packages
brew bundle list

# Check specific package
brew info <package-name>
```

## 🎉 Summary

**Dry Run Mode gives you:**
- ✅ Risk-free preview
- ✅ Understanding of what happens
- ✅ Confidence before running
- ✅ Ability to catch issues early
- ✅ Documentation of changes

**Always run dry-run first when:**
- Testing on a new machine
- After making changes to Brewfile
- Before recommending to others
- When unsure what will happen

**The install is safe to run when:**
- Dry run shows expected output
- You understand what will change
- Backups are in place (script does this)
- You've reviewed the code

---

**Pro Tip:** Dry run is your friend! Use it liberally. There's no cost to running it, and it can save you from surprises.

```bash
# Good practice
./install.sh --dry-run  # See what happens
# Review output
./install.sh            # Run if happy
```

