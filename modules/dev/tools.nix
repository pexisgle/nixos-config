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

    devenv
    mise
    bun

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
