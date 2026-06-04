{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lutris
    mangohud
    antigravity
    antigravity-cli
  ];
}
