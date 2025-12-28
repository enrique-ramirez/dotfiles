# Testing Checklist

Use this checklist to verify your dotfiles installation works correctly.

## ✅ Pre-Installation Tests

- [ ] Running on macOS (check: `sw_vers`)
- [ ] Have internet connection
- [ ] Have admin/sudo access
- [ ] Backed up important files

## ✅ Installation Tests

### Core Tools
- [ ] Homebrew installed (`brew --version`)
- [ ] Command Line Tools installed (`xcode-select -p`)
- [ ] Oh My Zsh installed (`ls -la ~/.oh-my-zsh`)
- [ ] NVM installed (`nvm --version`)
- [ ] Node.js LTS installed (`node --version`)
- [ ] pnpm installed (`pnpm --version`)

### CLI Utilities
- [ ] git (`git --version`)
- [ ] bat (`bat --version`)
- [ ] fzf (`fzf --version`)
- [ ] diff-so-fancy (`diff-so-fancy --version`)
- [ ] tig (`tig --version`)
- [ ] ripgrep (`rg --version`)
- [ ] tree (`tree --version`)
- [ ] jq (`jq --version`)
- [ ] wget (`wget --version`)

### GUI Applications
- [ ] Google Chrome (Check Applications folder)
- [ ] Visual Studio Code (`code --version`)
- [ ] Cursor (Check Applications folder)
- [ ] Figma (Check Applications folder)
- [ ] Slack (Check Applications folder)
- [ ] Spotify (Check Applications folder)
- [ ] 1Password (Check Applications folder)
- [ ] Dropbox (Check Applications folder)
- [ ] Ghostty (Check Applications folder)

### Configuration Files
- [ ] Ghostty config linked (`ls -la ~/.config/ghostty/config`)
- [ ] Git configured (`git config --list`)
- [ ] ZSH configured (`cat ~/.zshrc | grep "oh-my-zsh"`)
- [ ] fzf integrated (`cat ~/.zshrc | grep "fzf"`)

## ✅ Functionality Tests

### Git
```bash
# Test git aliases
git st  # Should show status
git br  # Should show branches
git lg  # Should show pretty log

# Test diff-so-fancy
git diff  # Should use diff-so-fancy
```

### Shell
```bash
# Test aliases
ll      # Should show detailed listing
cat README.md  # Should use bat with syntax highlighting
..      # Should go up one directory

# Test NVM
nvm ls  # Should show installed Node versions
```

### fzf
```bash
# Test fzf
Ctrl+R  # Should show command history with fzf
```

### Ghostty (if installed)
- [ ] Open Ghostty
- [ ] Check transparency (background-opacity = 0.8)
- [ ] Test hotkey (Ctrl+` should toggle visibility)
- [ ] Window size correct (1000x1000)

## ✅ Update Script Tests

```bash
./update.sh
```

- [ ] Homebrew updated
- [ ] Packages upgraded
- [ ] Oh My Zsh updated
- [ ] Node.js updated to latest LTS
- [ ] pnpm updated
- [ ] No errors during update

## ✅ Backup Script Tests

```bash
./backup.sh
```

- [ ] Backup directory created (`ls -la ~/.dotfiles_backup_*`)
- [ ] .zshrc backed up
- [ ] .gitconfig backed up
- [ ] Ghostty config backed up
- [ ] Homebrew packages listed

## ✅ Uninstall Script Tests

**WARNING**: Only test this if you're willing to remove configurations

```bash
./uninstall.sh
```

- [ ] Symlinks removed
- [ ] Original files preserved
- [ ] Can reinstall cleanly

## ✅ Integration Tests

### New Terminal Session
- [ ] Open new terminal
- [ ] Oh My Zsh loads correctly
- [ ] Git aliases work
- [ ] Shell aliases work
- [ ] NVM is available
- [ ] Node is available
- [ ] pnpm is available

### Projects Directory
- [ ] ~/Projects exists
- [ ] Can create new projects
- [ ] Git commands work

### Development Workflow
```bash
# Create test project
mkdir -p ~/Projects/test-project
cd ~/Projects/test-project
git init
nvm use --lts
pnpm init
pnpm add react

# Test
- [ ] Directory created
- [ ] Git initialized
- [ ] Node version correct
- [ ] pnpm works
- [ ] Package installed
```

## ✅ Brewfile Tests

```bash
# Check Brewfile
cd ~/Projects/dotfiles
brew bundle check
```

- [ ] All packages installed
- [ ] No missing packages
- [ ] No errors

```bash
# Test cleanup
brew bundle cleanup --dry-run
```

- [ ] Shows what would be removed
- [ ] Nothing critical flagged

## 🔍 Troubleshooting Tests

If any test fails, check:

1. **Homebrew Issues**
```bash
brew update
brew doctor
```

2. **NVM Issues**
```bash
echo $NVM_DIR
cat ~/.zshrc | grep NVM
```

3. **Path Issues**
```bash
echo $PATH
```

4. **Permission Issues**
```bash
ls -la ~/.config/ghostty/
```

## 📝 Test Results

Date: _______________

System: _______________

macOS Version: _______________

Results:
- Total Tests: _____
- Passed: _____
- Failed: _____
- Skipped: _____

Notes:
_______________________________________
_______________________________________
_______________________________________

## ✨ Success Criteria

All tests should pass except:
- Applications not available via Homebrew (expected manual install)
- Optional features you chose not to install

If 90%+ of tests pass, your installation is successful! 🎉

