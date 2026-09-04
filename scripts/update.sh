#!/usr/bin/env bash
# Wrapper for updating Nix flake inputs and custom packages.
# Locally runs the same updaters that the GitHub Actions workflow uses.
#
# Usage:
#   ./scripts/update.sh                       # update everything (flake + all pkgs)
#   ./scripts/update.sh flake                 # update flake.lock only
#   ./scripts/update.sh pkgs                  # update all custom packages only
#   ./scripts/update.sh opencodex             # update opencodex only
#   ./scripts/update.sh github-desktop-plus   # update github-desktop-plus only
#   FLAKE_INPUTS=nixpkgs ./scripts/update.sh flake   # update specific flake input
#   DRY_RUN=1 ./scripts/update.sh             # preview only (discards changes after run)
set -euo pipefail

script_dir="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd -- "$script_dir/.." && pwd)"
cd "$root"

target="${1:-all}"
dry_run="${DRY_RUN:-0}"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; }

run_flake() {
  if [[ -n "${FLAKE_INPUTS:-}" ]]; then
    log "Updating flake.lock (inputs: $FLAKE_INPUTS)..."
    # shellcheck disable=SC2086
    nix flake update $FLAKE_INPUTS
  else
    log "Updating flake.lock (all inputs)..."
    nix flake update
  fi
}

run_opencodex() {
  log "Updating opencodex..."
  "$script_dir/update-opencodex.sh"
}

run_github_desktop_plus() {
  log "Updating github-desktop-plus..."
  "$script_dir/update-github-desktop-plus.sh"
}

case "$target" in
  all)
    run_flake
    run_opencodex
    run_github_desktop_plus
    ;;
  flake)
    run_flake
    ;;
  pkgs)
    run_opencodex
    run_github_desktop_plus
    ;;
  opencodex)
    run_opencodex
    ;;
  github-desktop-plus)
    run_github_desktop_plus
    ;;
  *)
    err "Unknown target: $target (use: all | flake | pkgs | opencodex | github-desktop-plus)"
    exit 1
    ;;
esac

if [[ "$dry_run" == "1" ]]; then
  warn "DRY_RUN=1 — discarding updater-owned changes only"
  git restore --staged --worktree -- flake.lock pkgs/opencodex.nix pkgs/opencodex/package.json pkgs/opencodex/package-lock.json pkgs/github-desktop-plus.nix 2>/dev/null || true
  exit 0
fi

if [[ -n "$(git status --porcelain -- flake.lock pkgs/)" ]]; then
  log "Changes detected. Showing diff summary:"
  git status --short -- flake.lock pkgs/
  log "Review with: git diff -- flake.lock pkgs/"
  log "Commit with: git add -A && git commit -m 'chore: update'"
else
  log "Nothing to update — already on latest."
fi
