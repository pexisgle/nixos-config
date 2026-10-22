{ pkgs, ... }:

{
  # Desktop-only gaming packages.
  # System-level gaming services (Steam, Sunshine) are in ../nixos/gaming.nix.
  home.packages = with pkgs; [
    lutris
    mangohud
  ];
}
