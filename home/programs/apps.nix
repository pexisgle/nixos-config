{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gcr
    kitty
    xwayland-satellite
    nixd
    gh
    github-desktop-plus
    floorp-bin
    google-chrome
    vesktop
    slack
    notion-app-enhanced
    vlc
    antigravity
    antigravity-ide
    antigravity-cli
    opencode
    opencode-desktop
    zed-editor-fhs
    devenv
    mise
    secretspec
    lutris
    mangohud
  ];
}