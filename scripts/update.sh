#!/usr/bin/env bash
# Wrapper for the GitHub Actions update workflow.
# Locally runs the same updaters that the workflow uses, with sensible flags.
set -euo pipefail

script_dir="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd -- "$script_dir/.." && pwd)"
cd "$root"

target="${1:-all}"
dry_run="${DRY_RUN:-0}"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; }

run_hub() {
  log "Updating antigravity-hub..."
  bash pkgs/antigravity-hub/update.sh
}

run_cli() {
  log "Updating antigravity-cli..."
  if ! command -v nix >/dev/null 2>&1; then
    err "nix not found in PATH"
    return 1
  fi
  local base="https://storage.googleapis.com/antigravity-public/antigravity-cli"
  local version exec_id
  version="$(curl -fsSL https://antigravity.google/api/cli/latest 2>/dev/null | jq -r '.version // empty')"
  exec_id="$(curl -fsSL https://antigravity.google/api/cli/latest 2>/dev/null | jq -r '.execId // empty')"
  if [[ -z "$version" || -z "$exec_id" ]]; then
    warn "Could not probe latest CLI; pass version+urls manually:"
    warn "  pkgs/antigravity-cli/update.sh <version> <system> <url> ..."
    return 0
  fi
  log "Latest cli: $version ($exec_id)"
  declare -A urls=(
    [x86_64-linux]="${version}-${exec_id}/linux-x64/cli_linux_x64.tar.gz"
    [aarch64-linux]="${version}-${exec_id}/linux-arm/cli_linux_arm64.tar.gz"
    [aarch64-darwin]="${version}-${exec_id}/darwin-arm/cli_mac_arm64.tar.gz"
    [x86_64-darwin]="${version}-${exec_id}/darwin-x64/cli_mac_x64.tar.gz"
  )
  local args=("$version")
  for system in x86_64-linux aarch64-linux aarch64-darwin x86_64-darwin; do
    args+=("$system" "${base}/${urls[$system]}")
  done
  bash pkgs/antigravity-cli/update.sh "${args[@]}"
}

run_flake() {
  log "Updating flake.lock..."
  nix flake update
}

case "$target" in
  all)
    run_hub; run_cli; run_flake
    ;;
  antigravity-hub) run_hub ;;
  antigravity-cli) run_cli ;;
  flake)           run_flake ;;
  *)
    err "Unknown target: $target (use: all | antigravity-hub | antigravity-cli | flake)"
    exit 1
    ;;
esac

if [[ "$dry_run" == "1" ]]; then
  warn "DRY_RUN=1 — discarding changes"
  git restore --staged --worktree . 2>/dev/null || true
  exit 0
fi

if [[ -n "$(git status --porcelain)" ]]; then
  log "Changes detected. Showing diff summary:"
  git status --short
  log "Review with: git diff"
  log "Commit with: git add -A && git commit -m 'chore: update'"
else
  log "Nothing to update — already on latest."
fi
