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

run_flake() {
  log "Updating flake.lock..."
  nix flake update
}

case "$target" in
  all)
    run_hub; run_flake
    ;;
  antigravity-hub) run_hub ;;
  flake)           run_flake ;;
  *)
    err "Unknown target: $target (use: all | antigravity-hub | flake)"
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
