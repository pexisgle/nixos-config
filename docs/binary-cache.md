# Binary cache setup

This repository uses several upstream binary caches in `modules/core/nix.nix`, but locally modified and repository-local derivations cannot be served by `cache.nixos.org` under their original store paths.

Examples include:

- `github-desktop-plus`
- `opencodex`
- packages produced directly by external flake inputs when their upstream cache does not contain the exact locked revision

## Cache list source of truth

The cache URLs and keys live in `lib/caches.nix` for the NixOS side
(`modules/core/nix.nix`) and as mirror literals in `flake.nix` `nixConfig`
(which must stay literal, so it cannot import the file). Keep both in sync;
`./scripts/check-caches.sh` verifies the mirror and CI runs it.

## Repository Cachix cache

The repository-owned cache is `pexisgle` (`https://pexisgle.cachix.org`).

`.github/workflows/cache.yml` builds both NixOS system closures on pushes to `main`. When `CACHIX_AUTH_TOKEN` is configured, newly built store paths are uploaded to this cache. Without the secret, the workflow still validates both builds but skips upload.

One-time setup:

1. Add a GitHub Actions secret named `CACHIX_AUTH_TOKEN` containing a token with write access to the `pexisgle` cache.
2. Enable the cache on each NixOS host with:

   ```sh
   nix run nixpkgs#cachix -- use pexisgle
   ```

No repository variable is required because the cache name is fixed in the workflow.

## Numtide binary cache

`numtide/llm-agents.nix` provides prebuilt packages (such as `chatgpt`) via the Numtide binary cache (`https://cache.numtide.com`), which is configured in `modules/core/nix.nix`.

## FlakeHub Cache in CI workflows

Both `.github/workflows/cache.yml` and `.github/workflows/update.yml` use FlakeHub Cache alongside Cachix. FlakeHub Cache caches intermediate store paths within GitHub Actions storage, while Cachix distributes final packages to user hosts.

## Upstream binary caches via flake.nix

Upstream caches (Numtide, niri, lanzaboote, etc.) are configured in `flake.nix` under `nixConfig` as well as `modules/core/nix.nix`. This allows CI runners (with `accept-flake-config = true`) and CLI builds to resolve upstream binary substituters directly without requiring manual system-level configuration on the host.
