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

> The clone location is up to you — every script resolves paths from its own
> location, and the `dotfiles` shell alias follows the repo wherever it lives.

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
| `jq` | JSON processor (also powers the cooldown checks) |
| `tig` | Text-mode git interface |
| `lazygit` | Terminal UI for git (aliased as `lzg`) |
| `tldr` | Simplified man pages |
| `diff-so-fancy` | Better git diffs |
| `wget` | Download utility |
| `aria2` | Downloads with BitTorrent/HTTP/FTP support |
| `mas` | Mac App Store CLI |
| `duti` | Sets default apps per file type ([used for MIDI](#sheet-music--midi)) |
| `pyenv` | Python version manager |
| `libpq` | PostgreSQL client tools (`psql`, `pg_dump`, `pg_restore`) |
| `droast` | Opinionated Dockerfile linter |
| `zsh-autosuggestions` | Suggests commands from history as you type |
| `zsh-syntax-highlighting` | Highlights valid/invalid commands at the prompt |

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
- Spotify, IINA (media player)

**Sheet Music:**
- MuseScore ([default handler for `.mid`](#sheet-music--midi))

**Utilities:**
- The Unarchiver, QuickLook Video

**Mac App Store** (requires sign-in):
- Spark (email), Xcode

### ⚙️ Development Environment

- **Homebrew** — Package manager
- **Oh My Zsh** — Enhanced shell with plugins (git, docker, node, npm, nvm, macos, z)
- **NVM** — Node version manager (installs latest LTS)
- **pnpm** — Fast package manager
- **pyenv** — Python version manager (installs latest Python 3)
- **Claude Code** — AI coding assistant CLI
- **Google Cloud SDK** — GCP CLI tools
- **Cloud SQL Auth Proxy** — Connect to Cloud SQL instances

### 📝 Configurations

- Git config with aliases and diff-so-fancy
- Zed settings, symlinked so they sync across machines
- Ghostty terminal with global hotkey (`Ctrl+\``)
- Shell aliases (see `configs/zshrc`)
- SSH key generation for GitHub
- SSH commit signing, including the `allowed_signers` file
- fzf and gcloud shell integrations

## Usage

### Scripts

**Day to day, `./update.sh` is the only command you need** — it re-applies your
configuration and then updates everything.

```bash
./update.sh           # Apply config + update everything (the usual command)
./update.sh --skip-macos  # ...but skip the macOS software update check
./update.sh --no-install  # ...and skip the config pass (updates only)

./install.sh          # Full installation (first run on a new Mac)
./install.sh --dry-run # Preview without making changes
./install.sh --help   # Show help

./backup.sh           # Backup current configurations
./uninstall.sh        # Remove symlinks and optionally prune packages
```

### install.sh vs update.sh

They converge different things, which is why `update.sh` runs `install.sh` for you:

| | `install.sh` | `update.sh` |
|---|---|---|
| **Converges** | presence & configuration | versions |
| Symlinks, shell wiring, SSH keys | ✅ | via `install.sh` |
| Installs *missing* Brewfile packages | ✅ | via `install.sh` |
| Upgrades *outdated* packages | ❌ | ✅ |
| Node, pnpm, Claude Code, gcloud, Python, macOS | only if absent | upgraded |

Everything `install.sh` manages sits behind an "already installed? skip" guard —
that is what makes it safe to re-run, and also why it never upgrades anything on
its own. Running only `install.sh` would freeze every version indefinitely.

`update.sh` invokes `install.sh --no-summary` first and skips its own `brew
update` / Brewfile sync afterwards, so nothing is done twice. If `install.sh`
fails, `update.sh` warns and carries on with the updates.

> ⚠️ `uninstall.sh` offers an optional cleanup that removes Homebrew packages
> and App Store apps **not** listed in the Brewfile — that includes preinstalled
> Apple apps like Keynote and Pages. It shows the full plan and requires you to
> type `yes` before touching anything.

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
├── install.sh          # Applies configuration, installs anything missing
├── update.sh           # Runs install.sh, then upgrades everything
├── backup.sh           # Backup configurations
├── uninstall.sh        # Remove symlinks, optionally prune packages
├── Brewfile            # Homebrew packages
├── lib/
│   └── cooldown.sh     # Supply-chain release cooldown checks
└── configs/
    ├── zshrc           # Shell aliases, env vars, zsh plugins
    ├── gitconfig       # Git configuration
    ├── ghostty.txt     # Ghostty terminal config
    └── zed/
        └── settings.json  # Zed editor settings
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

Zed is also the git editor (`core.editor = zed --wait`), so `install.sh` verifies the `zed` CLI is on `PATH` and links it into `/usr/local/bin` if Zed was installed by hand rather than via Homebrew. Without that CLI, every `git commit` and interactive rebase would fail to open an editor.

## Sheet Music & MIDI

Double-clicking a `.mid` file on a stock Mac opens **GarageBand**, because it claims the `public.midi-audio` UTI in LaunchServices. That's a multi-gigabyte DAW for a few KB of note data. `install.sh` reassigns MIDI to **MuseScore** via `duti`:

```bash
duti -x mid    # verify which app currently handles MIDI
```

`install.sh` reads the bundle ID out of the installed `MuseScore *.app` rather than hardcoding it, then runs `duti -s <id> <type> all` for `public.midi-audio`, `.mid`, `.midi`, and `.kar`. If MuseScore or `duti` is missing it warns and moves on instead of failing the run.

MuseScore renders the notation *and* plays it with its own bundled sounds, so there's no SoundFont file for this repo to manage.

### Why not a CLI player

`wildmidi` and `timidity` are both in Homebrew, but neither bottle ships instrument samples — they need a GUS patch set wired up by hand and give you no way to *see* a score. Not worth it for double-click playback.

For the record, macOS does have a built-in General MIDI bank at `/System/Library/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls`, usable by anything driving AudioToolbox. VLC's macOS build reaches it through `libaudiotoolboxmidi_plugin.dylib` with no SoundFont configured — but VLC 3.0.23's GUI is unstable on current macOS, so it isn't the handler here.

### Legacy notation formats

Old score files in `.sib` and `.mus` are **not** openable by MuseScore, and there is no free offline conversion path on macOS:

| Format | Magic bytes | Status |
|---|---|---|
| `.mid` | `MThd` | ✅ Opens in MuseScore |
| `.mus` | `ENIGMA BINARY FILE` | ❌ Finale native; Finale discontinued Aug 2024 |
| `.sib` | `\x0fSIBELIUS` | ❌ Sibelius native, encrypted payload |

Both need MusicXML exported from the originating app. Free Sibelius First cannot export MusicXML (needs paid Sibelius Artist), and pre-2014.5 Finale needs the Dolet plugin. The [`musx2mxl`](https://github.com/joris-vaneyghen/musx2mxl) converter handles Finale's newer `.musx` only, not the older Enigma `.mus`. Online converters exist but require uploading the files.

Check what you're holding before hunting for a converter:

```bash
head -c 32 score.mus | xxd    # ENIGMA BINARY FILE = Finale
```

## Commit Signing

Commits are signed with your SSH key (`gpg.format = ssh`), not GPG. `install.sh` generates the key, then adds it to `~/.ssh/allowed_signers` so git can *verify* signatures locally — without that file `git log --show-signature` reports the key as unknown.

The same key has to be registered on GitHub **twice** for commits to show as Verified:

1. As an **Authentication key** — lets you push over SSH
2. As a **Signing key** — makes GitHub trust the signature

Both are added at https://github.com/settings/ssh/new, picking the appropriate "Key type" each time.

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

**Autosuggestions/syntax highlighting not working:**
These are Homebrew formulae sourced at the end of `configs/zshrc`, not Oh My Zsh
plugins — syntax highlighting has to load last or it silently stops working.
Verify they are installed and that `configs/zshrc` is sourced from `~/.zshrc`:
```bash
brew list zsh-autosuggestions zsh-syntax-highlighting
grep "Source custom dotfiles configuration" ~/.zshrc
```

**`nvm is not compatible with the "npm_config_prefix" environment variable`:**
Some tools (Zed's agent runner among them) export `npm_config_prefix`, which
makes nvm refuse to load. The scripts unset it for their own process; for your
shell, run `unset npm_config_prefix`.

## How It Works

- **Idempotent** — Safe to run multiple times
- **Non-destructive** — Backs up existing configs before overwriting
- **Apple Silicon ready** — Handles `/opt/homebrew` path correctly
- **Graceful failures** — Continues if some packages fail (e.g., App Store apps)

---

**First time?** Run `./install.sh --dry-run` to preview!
