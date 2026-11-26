{ pkgs, ... }:

{
  programs.noctalia.settings.brightness.enable_ddcutil = true;

  home.packages = with pkgs; [
    lutris
    mangohud
  ];
}
