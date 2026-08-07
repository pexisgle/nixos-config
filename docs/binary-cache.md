# Binary cache setup

This repository uses several upstream binary caches in `modules/core/nix.nix`, but locally modified and repository-local derivations cannot be served by `cache.nixos.org` under their original store paths.

Examples include:

- `github-desktop-plus`
- `opencodex`
- `claude-auto-retry`
- packages produced directly by external flake inputs when their upstream cache does not contain the exact locked revision

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

## Codex Desktop Linux

`codex-desktop-linux` publishes an upstream Cachix cache. The repository cache workflow always enables that cache for pulling, avoiding a local CI rebuild when the exact locked output is already available upstream.

For local machines, enable it directly as well:

```sh
nix run nixpkgs#cachix -- use codex-desktop-linux
```

## FlakeHub Cache in update CI

The existing dependency update workflow uses FlakeHub Cache. It now builds the desktop and laptop system closures after updating `flake.lock`, so successful update runs cache actual build outputs instead of evaluation metadata only.

FlakeHub Cache is primarily useful to the CI workflow. The `pexisgle` Cachix cache is the portable cache intended for normal NixOS hosts.
