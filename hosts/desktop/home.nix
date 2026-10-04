# Desktop-only Home Manager settings; shared settings come from modules/home.nix.
{ pkgs, ... }:

{
  imports = [
    ../../modules/home.nix
  ];

  home.packages = with pkgs; [
    lutris
    mangohud
  ];
}
