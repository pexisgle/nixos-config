{ pkgs, inputs, ... }:

{
  imports = [
    inputs.niri.homeModules.niri
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    ./desktop/material-shell.nix
    ./desktop/niri.nix
    ./desktop/xdg.nix
    ./programs/apps.nix
    ./programs/shell.nix
    ./programs/vscode.nix
  ];

  home.username = "pexisgle";
  home.homeDirectory = "/home/pexisgle";
  home.stateVersion = "25.11";
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
    zed-editor-fhs
    devenv
    mise
    secretspec
    kicad
  ];

  home.sessionVariables = {
    KICAD10_SYMBOL_DIR = "${pkgs.kicad.libraries.symbols}/share/kicad/symbols";
    KICAD10_FOOTPRINT_DIR = "${pkgs.kicad.libraries.footprints}/share/kicad/footprints";
    KICAD10_TEMPLATE_DIR = "${pkgs.kicad.libraries.symbols}/share/kicad/template";
  };

  programs.home-manager.enable = true;
}
