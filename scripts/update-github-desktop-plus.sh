#!/usr/bin/env bash
# Update github-desktop-plus package to the latest release on GitHub
set -euo pipefail

script_dir="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd -- "$script_dir/.." && pwd)"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; }

PKG_NIX="$root/pkgs/github-desktop-plus.nix"

if [[ ! -f "$PKG_NIX" ]]; then
  err "File not found: $PKG_NIX"
  exit 1
fi

log "Checking latest github-desktop-plus tag from GitHub..."
LATEST_TAG=$(curl -fsSL https://api.github.com/repos/pol-rivero/github-desktop-plus/tags | jq -er '.[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1)

if [[ -z "$LATEST_TAG" ]]; then
  err "Failed to fetch tags from GitHub API."
  exit 1
fi

LATEST_VERSION="${LATEST_TAG#v}"
CURRENT_VERSION=$(grep -oE 'version = "[^"]+"' "$PKG_NIX" | head -n 1 | cut -d'"' -f2)

log "Current version: $CURRENT_VERSION"
log "Latest version:  $LATEST_VERSION ($LATEST_TAG)"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  log "github-desktop-plus is already up to date ($CURRENT_VERSION)."
  exit 0
fi

log "Updating github-desktop-plus to $LATEST_VERSION..."

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

log "Prefetching git repository..."
PREFETCH_JSON=$(nix shell --inputs-from . nixpkgs#nix-prefetch-git --command nix-prefetch-git \
  --url https://github.com/pol-rivero/github-desktop-plus.git \
  --rev "$LATEST_TAG" \
  --fetch-submodules)
SRC_HASH=$(echo "$PREFETCH_JSON" | jq -r .hash)
log "Git source hash: $SRC_HASH"

log "Cloning repository for yarn lock hash calculation..."
git clone --depth 1 --branch "$LATEST_TAG" https://github.com/pol-rivero/github-desktop-plus.git "$TMP_DIR/repo"

log "Calculating root yarn.lock hash..."
ROOT_YARN_OUTPUT=$(nix shell --inputs-from . nixpkgs#prefetch-yarn-deps --command prefetch-yarn-deps "$TMP_DIR/repo/yarn.lock")
ROOT_YARN_BASE32=$(echo "$ROOT_YARN_OUTPUT" | grep -v 'ignoring lockfile entry' | tr -d '[:space:]')
ROOT_YARN_HASH=$(nix hash convert --to sri --hash-algo sha256 "$ROOT_YARN_BASE32")

log "Calculating app/yarn.lock hash..."
APP_YARN_OUTPUT=$(nix shell --inputs-from . nixpkgs#prefetch-yarn-deps --command prefetch-yarn-deps "$TMP_DIR/repo/app/yarn.lock")
APP_YARN_BASE32=$(echo "$APP_YARN_OUTPUT" | grep -v 'ignoring lockfile entry' | tr -d '[:space:]')
APP_YARN_HASH=$(nix hash convert --to sri --hash-algo sha256 "$APP_YARN_BASE32")

log "Root yarn hash: $ROOT_YARN_HASH"
log "App yarn hash:  $APP_YARN_HASH"

log "Updating $PKG_NIX..."
# Update version
sed -i -E "s|version = \".*\";|version = \"${LATEST_VERSION}\";|" "$PKG_NIX"

# Update source hash
sed -i -E "s|hash = \"sha256-.*\";|hash = \"${SRC_HASH}\";|" "$PKG_NIX"

# Update yarn lock hashes in customFetchYarnDeps
sed -i -E "/hasSuffix \"app\/yarn.lock\"/,/else/ s|\"sha256-.*\"|\"${APP_YARN_HASH}\"|" "$PKG_NIX"
sed -i -E "/else/,/};/ s|\"sha256-.*\"|\"${ROOT_YARN_HASH}\"|" "$PKG_NIX"

log "Successfully updated github-desktop-plus to $LATEST_VERSION"
