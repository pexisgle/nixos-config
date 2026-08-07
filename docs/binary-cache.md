# Binary cache setup

This repository uses several upstream binary caches in `modules/core/nix.nix`, but locally modified and repository-local derivations cannot be served by `cache.nixos.org` under their original store paths.

Examples include:

- `github-desktop-plus`
- `opencodex`
- `claude-auto-retry`
- packages produced directly by external flake inputs when their upstream cache does not contain the exact locked revision

## Repository Cachix cache

`.github/workflows/cache.yml` can build both NixOS system closures on pushes to `main` and upload newly built store paths to a Cachix cache.

One-time setup:

1. Create a Cachix cache.
2. Add a GitHub Actions repository variable named `CACHIX_CACHE_NAME` containing the cache name.
3. Add a GitHub Actions secret named `CACHIX_AUTH_TOKEN` containing a token with write access to that cache.
4. Enable the same cache on each NixOS host with:

   ```sh
   cachix use <cache-name>
   ```

The cache workflow is intentionally skipped until `CACHIX_CACHE_NAME` is configured.

## Codex Desktop Linux

`codex-desktop-linux` publishes an upstream Cachix cache. The repository cache workflow pulls from it with `extraPullNames: codex-desktop-linux`, avoiding a local CI rebuild when the exact locked output is already available upstream.

For local machines, enable it directly as well:

```sh
cachix use codex-desktop-linux
```

## FlakeHub Cache in update CI

The existing dependency update workflow uses FlakeHub Cache. It now builds the desktop and laptop system closures after updating `flake.lock`, so successful update runs cache actual build outputs instead of evaluation metadata only.

FlakeHub Cache is primarily useful to the CI workflow. The Cachix workflow above is the portable cache intended for normal NixOS hosts.
