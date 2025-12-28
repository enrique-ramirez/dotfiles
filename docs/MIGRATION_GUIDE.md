# Migration Guide: From init.sh to Modern Dotfiles Setup

## 🎯 What Changed & Why

### Before (init.sh)
- Single monolithic script
- Manual error-prone installations
- No configuration management
- Hard to maintain and debug
- Breaking issues when packages fail

### After (Modern Approach)
- **Brewfile**: Declarative package management
- **Modular Scripts**: Install, update, backup, uninstall
- **Config Management**: Symlinked configuration files
- **Better Error Handling**: Graceful failures with clear messages
- **Industry Standard**: Following best practices

## 📊 Feature Comparison

| Feature | Old (init.sh) | New (install.sh + Brewfile) |
|---------|---------------|------------------------------|
| Package Installation | Manual curl commands | Homebrew Bundle |
| Idempotency | Partial | Full ✓ |
| Error Handling | Basic | Comprehensive ✓ |
| Config Management | None | Symlinks ✓ |
| Update Mechanism | None | update.sh ✓ |
| Backup System | None | backup.sh ✓ |
| GUI Apps | Manual links | Automated ✓ |
| Cross-platform | macOS only | macOS (expandable) |
| Maintenance | Difficult | Easy ✓ |

## 🔄 What's the Same

Both approaches install:
- ✓ Oh My Zsh
- ✓ NVM + Node.js LTS
- ✓ pnpm
- ✓ Homebrew
- ✓ bat
- ✓ fzf
- ✓ diff-so-fancy
- ✓ Git configuration

## ⭐ What's New

Additional features in the new setup:

1. **New Packages**
   - `tig` - Text-mode git interface
   - `ripgrep` - Fast search tool
   - `tree` - Directory viewer
   - `jq` - JSON processor
   - `wget` - Download utility

2. **GUI Applications (Automated)**
   - Google Chrome
   - Visual Studio Code
   - Cursor
   - Figma
   - Slack
   - Spotify
   - 1Password
   - Dropbox
   - Ghostty

3. **Configuration Files**
   - Ghostty config (symlinked)
   - Git config file
   - Custom ZSH config
   - Shell aliases

4. **Maintenance Scripts**
   - `update.sh` - Update all packages
   - `backup.sh` - Backup configurations
   - `uninstall.sh` - Clean removal

5. **Better Documentation**
   - Comprehensive README
   - Quick reference guide
   - This migration guide
   - Changelog

## 🚀 Migration Steps

If you have an existing system with the old setup:

### 1. Backup Current Setup
```bash
./backup.sh
```

### 2. Review What's Installed
```bash
brew list --formula > ~/old_packages.txt
brew list --cask > ~/old_apps.txt
```

### 3. Run New Install
```bash
./install.sh
```

The new script will:
- Skip already installed packages ✓
- Not break if something fails ✓
- Preserve your existing configurations ✓

### 4. Verify Installation
```bash
# Check Homebrew packages
brew bundle check

# Check Node
node --version

# Check shell
echo $SHELL
```

### 5. Clean Up (Optional)
```bash
# Remove old script
rm init.sh.old

# Clean old Homebrew packages
brew bundle cleanup
```

## 🏗️ Architecture Overview

### New Structure
```
dotfiles/
├── Brewfile              # Package definitions (like package.json)
├── install.sh            # Main installation script
├── update.sh             # Update all packages
├── backup.sh             # Backup configurations
├── uninstall.sh          # Remove symlinks
├── configs/              # Configuration files
│   ├── ghostty.txt       # Terminal config
│   ├── gitconfig         # Git config
│   ├── zshrc             # Shell config
│   └── README.md         # Config documentation
├── README.md             # Main documentation
├── QUICK_REFERENCE.md    # Command cheatsheet
├── CHANGELOG.md          # Version history
└── .gitignore            # Git ignore rules
```

## 💡 Key Improvements Explained

### 1. Homebrew Bundle (Brewfile)
**Why?** Industry standard for macOS package management

```ruby
# Before: Manual curl + installation
curl -fsSL https://install.sh | sh

# After: Declarative definition
brew "package-name"
cask "app-name"
```

Benefits:
- Reproducible installations
- Easy to share and version control
- Automatic dependency management
- Idempotent (safe to run multiple times)

### 2. Configuration Symlinks
**Why?** Keep configs in version control, linked to system locations

```bash
# Config stays in repo
~/Projects/dotfiles/configs/ghostty.txt

# Symlinked to where app expects it
~/.config/ghostty/config → ~/Projects/dotfiles/configs/ghostty.txt
```

Benefits:
- Track config changes in git
- Easy to restore
- Share configs across machines
- No manual copying

### 3. Modular Scripts
**Why?** Single responsibility, easier to maintain

```bash
install.sh   # One-time setup
update.sh    # Regular updates
backup.sh    # Safety first
uninstall.sh # Clean removal
```

Benefits:
- Clear purpose for each script
- Easier debugging
- Reusable components
- Better error isolation

### 4. Better Error Handling
**Why?** Fail gracefully, inform the user

```bash
# Before
brew install bat

# After
if command_exists bat; then
    print_success "Already installed"
else
    print_info "Installing bat..."
    brew install bat
    print_success "bat installed"
fi
```

Benefits:
- Won't crash if one package fails
- Clear feedback to user
- Idempotent behavior
- Better debugging

## 📚 Best Practices Implemented

1. **DRY (Don't Repeat Yourself)**
   - Helper functions for common tasks
   - Reusable components

2. **Fail Fast**
   - `set -e` to exit on errors
   - Check dependencies before running

3. **User Feedback**
   - Colored output for different message types
   - Progress indicators
   - Clear success/failure messages

4. **Idempotency**
   - Safe to run multiple times
   - Checks before installing
   - No duplicate work

5. **Version Control**
   - Everything in git
   - Meaningful commit messages
   - Changelog for tracking

6. **Documentation**
   - README for overview
   - Quick reference for daily use
   - Migration guide for transitions
   - Inline comments in code

## 🎓 Learning Resources

Want to learn more about dotfiles best practices?

- [GitHub Dotfiles Guide](https://dotfiles.github.io/)
- [Homebrew Bundle Documentation](https://github.com/Homebrew/homebrew-bundle)
- [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles)
- [Managing Your Dotfiles](https://www.anishathalye.com/2014/08/03/managing-your-dotfiles/)

## 🤔 FAQ

**Q: Can I keep using my old init.sh?**
A: Yes, but the new approach is more maintainable and follows industry standards.

**Q: Will this overwrite my existing configs?**
A: No, the script backs up existing files before creating symlinks.

**Q: What if I don't want a package from the Brewfile?**
A: Just remove the line from the Brewfile and run `brew bundle cleanup`.

**Q: Can I use this on multiple Macs?**
A: Yes! That's the whole point. Clone the repo on each Mac and run `./install.sh`.

**Q: How do I update my personal information?**
A: Edit `configs/gitconfig` and the relevant lines in `install.sh`.

## 🎉 Benefits of the New Approach

1. **Time Savings**: Faster setup on new machines
2. **Consistency**: Same environment everywhere
3. **Maintainability**: Easy to update and modify
4. **Reliability**: Fewer breaking changes
5. **Shareability**: Others can use your setup
6. **Documentation**: Clear understanding of what's installed
7. **Version Control**: Track changes over time
8. **Automation**: Less manual work
9. **Professional**: Industry-standard approach
10. **Peace of Mind**: Backups and safety checks built-in

