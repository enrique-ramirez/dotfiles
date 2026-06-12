#!/usr/bin/env bash

###############################################################################
# Supply-chain cooldown for Homebrew packages
#
# Only install/upgrade packages whose current version has been in the tap for
# at least COOLDOWN_HOURS. Compromised releases are usually detected and
# pulled within ~24h, so waiting 48h avoids most supply chain attacks.
#
# Homebrew taps only carry ONE version per package, so unlike npm we cannot
# fall back to an older version — too-fresh packages are deferred instead
# (upgrades keep the currently installed version; installs wait for a re-run).
#
# Requires: jq, curl. Sourced by install.sh and update.sh.
# Set GITHUB_TOKEN to avoid GitHub API rate limits (60 req/h anonymous).
###############################################################################

COOLDOWN_HOURS="${COOLDOWN_HOURS:-48}"

# ISO-8601 UTC timestamp of the cooldown cutoff (BSD date)
cooldown_cutoff() {
    date -u -v-"${COOLDOWN_HOURS}H" +%Y-%m-%dT%H:%M:%SZ
}

# Date of the last commit touching a file in a GitHub repo
# Args: repo (e.g. Homebrew/homebrew-core), file path
github_last_commit_date() {
    local repo="$1" path="$2"
    local auth=()
    [ -n "${GITHUB_TOKEN:-}" ] && auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
    curl -fsSL "${auth[@]}" \
        "https://api.github.com/repos/${repo}/commits?path=${path}&per_page=1" 2>/dev/null \
        | jq -r '.[0].commit.committer.date // empty' 2>/dev/null
}

# Check whether a brew package's current version satisfies the cooldown.
# A version bump is always a commit to the formula/cask file, so the file's
# last commit date is a conservative upper bound on the version's age.
# Args: type ("formula" or "cask"), package name
# Returns: 0 = old enough, 1 = too fresh, 2 = unknown (API/parse failure)
brew_cooldown_ok() {
    local type="$1" name="$2"
    local info tap src repo committed

    if [ "$type" = "cask" ]; then
        info=$(brew info --json=v2 --cask "$name" 2>/dev/null \
            | jq -r '.casks[0] | "\(.tap) \(.ruby_source_path)"' 2>/dev/null)
    else
        info=$(brew info --json=v2 --formula "$name" 2>/dev/null \
            | jq -r '.formulae[0] | "\(.tap) \(.ruby_source_path)"' 2>/dev/null)
    fi

    tap="${info%% *}"
    src="${info#* }"
    if [ -z "$tap" ] || [ "$tap" = "null" ] || [ -z "$src" ] || [ "$src" = "null" ]; then
        return 2
    fi

    # Tap "homebrew/core" lives at github.com/Homebrew/homebrew-core, etc.
    repo="${tap%%/*}/homebrew-${tap##*/}"

    committed=$(github_last_commit_date "$repo" "$src")
    if [ -z "$committed" ]; then
        return 2
    fi

    # ISO-8601 UTC strings compare correctly as plain strings
    if [[ "$committed" < "$(cooldown_cutoff)" ]]; then
        return 0
    fi
    return 1
}
