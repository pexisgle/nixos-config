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

  programs.home-manager.enable = true;
}
