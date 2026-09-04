#!/usr/bin/env bash
# Verify flake.nix nixConfig mirrors lib/caches.nix.
# flake nixConfig must stay a literal attrset (Nix reads it without full
# evaluation), so the NixOS-side lists live in lib/caches.nix and this
# script keeps both copies in sync. CI runs it; run it locally after
# editing either file.
set -euo pipefail

root="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

fail=0
check() {
  local name="$1" flake_expr="$2" lib_expr="$3"
  local flake_json lib_json
  flake_json="$(nix eval --impure --json --expr "$flake_expr")"
  lib_json="$(nix eval --impure --json --expr "$lib_expr")"
  if [[ "$flake_json" != "$lib_json" ]]; then
    printf "xx %s mismatch (flake.nix vs lib/caches.nix)\n" "$name" >&2
    fail=1
  else
    printf "=> %s OK\n" "$name"
  fi
}
check "extra-substituters" "(import ./flake.nix).nixConfig.extra-substituters" "(import ./lib/caches.nix).extraSubstituters"
check "extra-trusted-public-keys" "(import ./flake.nix).nixConfig.extra-trusted-public-keys" "(import ./lib/caches.nix).extraTrustedPublicKeys"

exit "$fail"
