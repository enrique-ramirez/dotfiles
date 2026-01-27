# Changelog

All notable changes to this dotfiles repository will be documented here.

## [2.1.2] - 2026-01-27

### Added
- **Ghostty global hotkey setup** moved early in installation process
- Automatic addition of Ghostty to Login Items (launches hidden at login)
- Interactive prompt to open Ghostty and grant Accessibility permissions
- `quit-after-last-window-closed = false` config to keep Ghostty running in background
- Detailed Ghostty documentation in README

### Changed
- Ghostty config now includes organized sections and documentation comments
- Ghostty setup happens right after Brewfile installation for faster availability

## [2.1.1] - 2026-01-27

### Fixed
- **Critical**: Fixed Homebrew PATH being lost when Oh My Zsh overwrites `.zshrc`
  - Homebrew PATH is now added AFTER Oh My Zsh installation
  - PATH is prepended to the file to ensure it loads first
- **Critical**: Fixed Oh My Zsh plugins not loading (plugins+=() doesn't work after oh-my-zsh.sh is sourced)
  - Plugins are now configured directly in `~/.zshrc` via sed
- Fixed fzf shell integration using deprecated `~/.fzf.zsh` method
  - Now uses modern `source <(fzf --zsh)` method
- Removed deprecated `homebrew/cask-fonts` tap (fonts now in main repo)
- Removed unused `mas` CLI (no Mac App Store apps are auto-installed)
- Added `chmod 600` on SSH config file for proper permissions
- Added check for `diff-so-fancy` existence before configuring git

### Changed
- Removed fzf integration from `configs/zshrc` (now added by install.sh to .zshrc directly)
- Removed plugins configuration from `configs/zshrc` (handled by install.sh)
- Added `NONINTERACTIVE=1` to Homebrew installer for cleaner automation
- Added bootstrap instructions to `--help` output
- Improved README with explicit fresh Mac bootstrap steps

## [2.1.0] - 2026-01-27

### Changed
- **BREAKING**: Removed auto-installation of GUI applications (Chrome, Spotify, Figma, Slack, Dropbox)
- Optional apps are now listed with download links at the end of installation
- Brewfile now only installs essential development tools and core apps (VSCode, Cursor, Ghostty)

### Added
- **1Password critical warning** at the start of installation - emphasized as essential first step
- **SSH key generation** for GitHub with automatic ssh-agent configuration
- Interactive prompts for SSH key setup and 1Password verification
- Comprehensive download links section at end of installation
- Better visual organization with boxed sections in terminal output
- SSH troubleshooting section in README

### Removed
- Auto-installation of: Google Chrome, Figma, Slack, Spotify, 1Password, Dropbox
- Mac App Store (mas) app installations

### Why These Changes
- Cask installations can fail on different systems due to signing requirements, missing dependencies, or app store restrictions
- Manual installation ensures apps work correctly on each specific machine
- 1Password is critical infrastructure and should be set up consciously, not silently
- SSH key setup ensures developers can immediately work with GitHub repositories

## [2.0.0] - 2025-12-28

### Changed
- **BREAKING**: Migrated from single script to Homebrew Bundle approach
- Restructured entire repository for better maintainability
- Improved error handling and user feedback

### Added
- `Brewfile` for declarative package management
- `install.sh` - Completely rewritten installation script
- `uninstall.sh` - Script to remove symlinks and optionally packages
- Configuration management with symlinks:
  - Ghostty terminal configuration
  - Git configuration with aliases
  - ZSH configuration with custom aliases
- Better visual feedback with colored output and symbols
- Idempotent installation (safe to run multiple times)
- Apple Silicon Mac support
- Automatic Node.js LTS installation via NVM
- More CLI tools: `tig`, `ripgrep`, `tree`, `jq`, `wget`
- Comprehensive README with troubleshooting
- `.gitignore` file

### Removed
- Old `init.sh` script (replaced by `install.sh`)
- Hardcoded configuration (moved to separate config files)

## [1.0.0] - Previous

### Initial Version
- Basic setup script (`init.sh`)
- Manual software installation list
- Basic Ghostty configuration
