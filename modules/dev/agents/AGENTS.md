# Global NixOS Development Rules

Scope: User-global defaults for software development on NixOS.

## 1. Environment & Command Execution
- **Standard Setup**: Manage project environments using `flake.nix` + `direnv` (`.envrc` with `use flake`).
- **Missing Flake**: If a project lacks a `flake.nix`, create a minimal one (`devShells`) matching the conventions used in `~/nixos-config`.
- **Running Commands**: In non-interactive shells, ALWAYS execute project commands via `direnv exec . <cmd>`. Fallback to `nix develop -c <cmd>` only if `direnv` fails.
- **Git & Lockfiles**: Commit `flake.lock`. NEVER run `nix flake update` unless explicitly instructed. Ensure `result`, `result-*`, and `.direnv/` are in `.gitignore`.

## 2. Toolchains vs. Library Dependencies
- **Nix (`devShell`)**: Use `flake.nix` ONLY for language toolchains (compilers, runtimes, package managers) and native C/system libraries (e.g., `pkg-config`, `openssl`).
- **Language Package Managers**: Manage project-level library dependencies using the language's native lockfile and package manager (`uv`, `bun`, `pnpm`, `cargo`, etc.) inside the `devShell`. Keep Python `.venv` inside the project directory.
- **Ephemeral / One-off Tools**:
  - General CLI tools: `nix shell nixpkgs#<pkg> -c <cmd>` or `nix run nixpkgs#<pkg>`
  - JS/TS: `bunx <pkg>`
  - Python: `nix shell nixpkgs#uv -c uvx <pkg>`
- **Permanent Global Tools**: Do not install imperatively. Add them to `~/nixos-config` (ask the user first).
- **Existing `mise` Projects**: Only use `mise` if the project already has `mise.toml`. Commit `mise.toml`, do not duplicate its runtimes in `devShell`, and run `mise install` if a runtime is `(missing)`.

## 3. Strictly Prohibited Commands (NEVER RUN)
Do NOT install packages globally or imperatively. The following are strictly forbidden:
- Nix imperative: `nix profile install`, `nix-env -i`
- Language globals: `npm i -g`, `bun i -g`, `pip install --user`, `cargo install`, `go install`, `mise use -g`
- External installers: `curl ... | sh`, `brew`, or placing binaries directly into `~/.local/bin`
- Toolchain mutators: `rustup` (use `rust-overlay` in Flake instead), `corepack enable` (fails due to read-only `/nix/store`; place `pnpm`/`yarn` in `devShell` instead).

## 4. NixOS Specific Constraints
- **Read-Only Store**: `/nix/store` is immutable. Never attempt to modify files inside it or use tools that write next to their own binary.
- **Prebuilt Binaries (`nix-ld`)**: `nix-ld` is enabled on this system, so most dynamically linked prebuilt binaries (e.g., Python wheels, `mise` runtimes) work out of the box. If a missing library error still occurs, add the required library to the project's `devShell` rather than patching binaries manually.
- **Sandboxed Builds**: Nix derivations (`nix build`) have NO network access. Do not run network-dependent tests in `checkPhase`; run them in `devShell` or CI instead.
- **Dotfiles & Shell Configs**: `~/.zshrc`, `/etc`, and core entries in `~/.config` are managed by Home Manager / NixOS in `~/nixos-config`. Never append `export PATH=...` or environment variables to `~/.zshrc` or `~/.bashrc`; configure them in the project's `.envrc` or `flake.nix` (`devShell`) instead.
- **Secrets**: Never hardcode secrets or API keys in source code, `flake.nix`, or committed `.envrc` files (note: files tracked by a Flake are copied to the world-readable `/nix/store`). Use `.gitignore`d `.env` files for local development.
