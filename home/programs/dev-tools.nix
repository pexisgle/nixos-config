{ pkgs, ... }:

{
  # Runtime roles (all four are intentional for now):
  # devenv = per-project dev shells, mise = toolchain version pinning,
  # bun = fast JS runtime for opencodex proxy, nodejs = LTS fallback.
  # Consolidate only after checking which projects rely on mise vs devenv.
  home.packages = with pkgs; [
    # Terminal / session
    gcr
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
    nodejs
    python3Packages.huggingface-hub

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
    opencode-desktop
    opencode2
    github-desktop-plus
    antigravity
    antigravity-cli
    code-cursor-fhs
    grok-bot
  ];
}
