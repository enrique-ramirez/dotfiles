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
brew "wget"             # Download utility
brew "tree"             # Directory structure viewer
brew "jq"               # JSON processor
brew "ripgrep"          # Better grep
brew "eza"              # Modern replacement for ls (better than exa)
brew "fd"               # Simple, fast alternative to find
brew "tldr"             # Simplified man pages
brew "mas"              # Mac App Store CLI (for installing App Store apps)

# ═══════════════════════════════════════════════════════════════════════════════
# DEVELOPMENT TOOLS (Always installed)
# ═══════════════════════════════════════════════════════════════════════════════

brew "pyenv"            # Python version manager

# Note: google-cloud-sdk is installed via official installer in install.sh
# (Homebrew formula is unreliable/deprecated)

# ═══════════════════════════════════════════════════════════════════════════════
# ESSENTIAL APPLICATIONS (Always installed)
# ═══════════════════════════════════════════════════════════════════════════════

# Development
cask "visual-studio-code"
cask "cursor"
cask "ghostty"
cask "docker"           # Docker Desktop (PostgreSQL etc. via containers)

# ═══════════════════════════════════════════════════════════════════════════════
# SECURITY & PASSWORDS
# ═══════════════════════════════════════════════════════════════════════════════

cask "1password"        # Password manager (install first, has all your keys!)

# ═══════════════════════════════════════════════════════════════════════════════
# BROWSERS
# ═══════════════════════════════════════════════════════════════════════════════

cask "google-chrome"
cask "zen-browser"

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
# DOWNLOAD UTILITIES
# ═══════════════════════════════════════════════════════════════════════════════

brew "aria2"                # Download utility with BitTorrent, HTTP/HTTPS, FTP support

# ═══════════════════════════════════════════════════════════════════════════════
# QUICKLOOK PLUGINS
# ═══════════════════════════════════════════════════════════════════════════════

cask "qlvideo"          # QuickLook support for webm, mkv, and other video formats

# ═══════════════════════════════════════════════════════════════════════════════
# MAC APP STORE (requires being signed into App Store)
# ═══════════════════════════════════════════════════════════════════════════════

mas "Spark – Email App by Readdle", id: 1176895641
mas "Xcode", id: 497799835
