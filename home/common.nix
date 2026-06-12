{ pkgs, inputs, ... }:

{
  imports = [
    inputs.niri.homeModules.niri
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    ./desktop/material-shell.nix
    ./desktop/niri.nix
    ./desktop/xdg.nix
    ./programs/browsers.nix
    ./programs/communication.nix
    ./programs/dev-tools.nix
    ./programs/gaming.nix
    ./programs/media.nix
    ./programs/opencode.nix
    ./programs/shell.nix
    ./programs/vscode.nix
  ];

  home.username = "pexisgle";
  home.homeDirectory = "/home/pexisgle";
  home.stateVersion = "26.05";
  home.packages = with pkgs; [
    kicad
    lmstudio
  ];

  home.sessionVariables = {
    KICAD10_SYMBOL_DIR = "${pkgs.kicad.libraries.symbols}/share/kicad/symbols";
    KICAD10_FOOTPRINT_DIR = "${pkgs.kicad.libraries.footprints}/share/kicad/footprints";
    KICAD10_TEMPLATE_DIR = "${pkgs.kicad.libraries.symbols}/share/kicad/template";
  };

  home.sessionPath = [
    "$HOME/.bun/bin"
  ];

  programs.home-manager.enable = true;
}
