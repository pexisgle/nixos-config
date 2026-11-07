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

    # file-search skill が想定する検索ツール一式。
    ripgrep
    fd
    ast-grep
    semgrep
    ripgrep-all
    tokei
    scc
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
