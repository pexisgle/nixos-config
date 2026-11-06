{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kitty
    tmux

    nixd
    nixfmt

    gh

    mise
    bun

    rtk

    ripgrep
    fd
    ast-grep
    jq

    just

    serena

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
