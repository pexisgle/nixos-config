{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gcr
    kitty
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
    zed-editor-fhs
    opencode-desktop
    github-desktop-plus
    antigravity
    antigravity-cli
    zmkbatx
  ];
}
