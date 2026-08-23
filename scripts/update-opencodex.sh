#!/usr/bin/env bash
# Update opencodex package to the latest version on npm
set -euo pipefail

script_dir="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd -- "$script_dir/.." && pwd)"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; }

PKG_NIX="$root/pkgs/opencodex.nix"
PKG_DIR="$root/pkgs/opencodex"

if [[ ! -f "$PKG_NIX" ]]; then
  err "File not found: $PKG_NIX"
  exit 1
fi

log "Checking latest opencodex version from npm..."
LATEST_VERSION=$(curl -sL https://registry.npmjs.org/@bitkyc08/opencodex | jq -r '."dist-tags".latest')
CURRENT_VERSION=$(grep -oP 'version = "\K[^"]+' "$PKG_NIX" | head -n 1)

log "Current version: $CURRENT_VERSION"
log "Latest version:  $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]] && [[ -f "$PKG_DIR/package-lock.json" ]]; then
  log "opencodex is already up to date ($CURRENT_VERSION)."
  exit 0
fi

log "Updating opencodex to $LATEST_VERSION..."
TARBALL_URL="https://registry.npmjs.org/@bitkyc08/opencodex/-/opencodex-${LATEST_VERSION}.tgz"

log "Prefetching unpacked tarball hash..."
PREFETCH_HASH=$(nix-prefetch-url --unpack "$TARBALL_URL" 2>/dev/null)
SRI_HASH=$(nix hash convert --to sri --hash-algo sha256 "$PREFETCH_HASH")
log "Calculated hash: $SRI_HASH"

log "Extracting package.json from tarball..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
curl -sL "$TARBALL_URL" | tar -xz -C "$TMP_DIR"
cp "$TMP_DIR/package/package.json" "$PKG_DIR/package.json"

log "Generating package-lock.json..."
(cd "$PKG_DIR" && npm install --package-lock-only --silent)

log "Updating $PKG_NIX..."
sed -i -E "s|version = \".*\";|version = \"${LATEST_VERSION}\";|" "$PKG_NIX"
sed -i -E "s|url = \"https://registry\.npmjs\.org/@bitkyc08/opencodex/-/opencodex-.*\.tgz\";|url = \"${TARBALL_URL}\";|" "$PKG_NIX"
sed -i -E "s|hash = \"sha256-.*\";|hash = \"${SRI_HASH}\";|" "$PKG_NIX"

log "Successfully updated opencodex to $LATEST_VERSION"
