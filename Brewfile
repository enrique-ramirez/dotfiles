# Brewfile for automated Mac setup
# Install with: brew bundle install

# ═══════════════════════════════════════════════════════════════════════════════
# ESSENTIAL CLI TOOLS (Always installed)
# ═══════════════════════════════════════════════════════════════════════════════

brew "git"
brew "bat"              # Better cat with syntax highlighting
brew "fzf"              # Fuzzy finder
brew "diff-so-fancy"    # Better git diffs
brew "tig"              # Text-mode interface for git
brew "lazygit"          # Terminal UI for git
brew "wget"             # Download utility
brew "tree"             # Directory structure viewer
brew "jq"               # JSON processor
brew "ripgrep"          # Better grep
brew "eza"              # Modern replacement for ls (better than exa)
brew "fd"               # Simple, fast alternative to find
brew "tldr"             # Simplified man pages
brew "mas"              # Mac App Store CLI (for installing App Store apps)

# Shell (sourced by configs/zshrc, not the Oh My Zsh plugin list)
brew "zsh-autosuggestions"       # Suggests commands from history as you type
brew "zsh-syntax-highlighting"   # Highlights valid/invalid commands at the prompt

# ═══════════════════════════════════════════════════════════════════════════════
# DEVELOPMENT TOOLS (Always installed)
# ═══════════════════════════════════════════════════════════════════════════════

brew "pyenv"            # Python version manager
brew "libpq"            # PostgreSQL client tools (psql, pg_dump, pg_restore)
brew "droast"           # Opinionated Dockerfile linter

# Note: google-cloud-sdk is installed via official installer in install.sh
# (Homebrew formula is unreliable/deprecated)

# ═══════════════════════════════════════════════════════════════════════════════
# C / C++ TOOLCHAIN
# ═══════════════════════════════════════════════════════════════════════════════

# The compiler itself comes from Xcode (see MAC APP STORE below), as does
# clang-format. clang-tidy does not ship with Xcode, which is the reason for llvm.

brew "llvm"             # clang-tidy and clangd. Keg-only, so not on PATH: scripts
                        # resolve it with `brew --prefix llvm`, and configs/zed
                        # points at /opt/homebrew/opt/llvm/bin/clangd
brew "bear"             # Records a build into compile_commands.json, so clangd can
                        # index a project that has no build system on this machine
brew "redocly-cli"      # Lints and bundles OpenAPI documents

# ═══════════════════════════════════════════════════════════════════════════════
# ESSENTIAL APPLICATIONS (Always installed)
# ═══════════════════════════════════════════════════════════════════════════════

# Development
cask "zed"              # Zed editor
cask "ghostty"
cask "orbstack"         # Docker engine + Linux VMs (lighter Docker Desktop replacement)
# cask "visual-studio-code"  # Removed 2026-06: no longer trusted, settings kept on disk
# cask "cursor"              # Removed 2026-06: no longer trusted, settings kept on disk
# cask "docker-desktop"      # Replaced 2026-06 by orbstack

# ═══════════════════════════════════════════════════════════════════════════════
# SECURITY & PASSWORDS
# ═══════════════════════════════════════════════════════════════════════════════

cask "1password"        # Password manager (install first, has all your keys!)

# ═══════════════════════════════════════════════════════════════════════════════
# BROWSERS
# ═══════════════════════════════════════════════════════════════════════════════

cask "google-chrome"
cask "zen"              # Zen Browser

# ═══════════════════════════════════════════════════════════════════════════════
# PRODUCTIVITY & COMMUNICATION
# ═══════════════════════════════════════════════════════════════════════════════

cask "figma"
cask "slack"
cask "clickup"
cask "dropbox"
cask "zoom"

# ═══════════════════════════════════════════════════════════════════════════════
# ENTERTAINMENT
# ═══════════════════════════════════════════════════════════════════════════════

cask "spotify"
cask "iina"                 # Modern macOS media player (plays everything)

# ═══════════════════════════════════════════════════════════════════════════════
# SHEET MUSIC & MIDI
# ═══════════════════════════════════════════════════════════════════════════════

cask "musescore"        # Notation viewer/player — opens .mid with bundled sounds
brew "duti"             # Sets default apps per file type (claims .mid for MuseScore)

# ═══════════════════════════════════════════════════════════════════════════════
# DOWNLOAD UTILITIES
# ═══════════════════════════════════════════════════════════════════════════════

brew "aria2"                # Download utility with BitTorrent, HTTP/HTTPS, FTP support

# ═══════════════════════════════════════════════════════════════════════════════
# UTILITIES
# ═══════════════════════════════════════════════════════════════════════════════

cask "the-unarchiver"   # Extract archives (zip, rar, 7z, tar, etc.)

# ═══════════════════════════════════════════════════════════════════════════════
# QUICKLOOK PLUGINS
# ═══════════════════════════════════════════════════════════════════════════════

cask "quicklook-video"  # QuickLook support for webm, mkv, and other video formats
# The old "qlvideo" cask is the same plugin under its former name. install.sh
# removes it if present, so both aren't registered as QuickLook generators.

# ═══════════════════════════════════════════════════════════════════════════════
# MAC APP STORE (requires being signed into App Store)
# ═══════════════════════════════════════════════════════════════════════════════

mas "Spark – Email App by Readdle", id: 1176895641
mas "Xcode", id: 497799835
