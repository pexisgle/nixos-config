{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gcr_4
    kitty
    tmux
    xwayland-satellite

    nixd
    nixfmt

    gh
    delta

    devenv
    mise
    bun
    wrangler

    rtk

    ripgrep
    fd
    ast-grep
    broot

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

    tokei
    hyperfine
    just
    watchexec

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
