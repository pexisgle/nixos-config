{ pkgs, ... }:

{
  # Runtime roles (all three are intentional for now):
  # devenv = per-project dev shells, mise = toolchain version pinning,
  # bun = fast JS runtime for opencodex proxy.
  # node/pnpm come from mise global defaults instead of nixpkgs.
  # Consolidate only after checking which projects rely on mise vs devenv.
  home.packages = with pkgs; [
    # Terminal / session
    gcr_4
    kitty
    tmux
    xwayland-satellite

    # Nix
    nixd
    nixfmt

    # VCS / GitHub
    gh
    delta

    # Runtimes / env
    devenv
    mise
    bun

    # Remote tooling helper (opencode rtk plugin dependency)
    rtk

    # Search, navigation, structural queries
    ripgrep
    fd
    ast-grep
    broot
    # NOTE: fzf/zoxide/eza/bat are enabled via programs.* in shell.nix
    # so their zsh integrations stay wired; do not re-add them here.

    # Modern CLI / file utilities
    sd
    dust
    duf
    procs
    tealdeer
    yazi
    ouch
    jless
    xh
    jq

    # Dev workflow
    tokei
    hyperfine
    just
    watchexec

    # Editors / AI coding tools
    zed-editor-fhs
    opencode2
    opencode2-desktop
    github-desktop-plus
    antigravity
    antigravity-cli
    command-code
    dsh
    deepseek-harness-desktop
  ];
}
