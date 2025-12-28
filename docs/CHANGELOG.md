# Changelog

All notable changes to this dotfiles repository will be documented here.

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

