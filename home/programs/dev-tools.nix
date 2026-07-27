{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gcr
    kitty
    tmux
    xwayland-satellite
    nixd
    nixfmt
    gh
    devenv
    mise
    secretspec
    bun
    nodejs
    rtk
    jq
    zed-editor-fhs
    claude-code
    opencode-desktop
    github-desktop-plus
    antigravity
    antigravity-cli
    code-cursor-fhs
  ];
}
