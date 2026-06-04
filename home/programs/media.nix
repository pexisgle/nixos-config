{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vlc
    gimp
  ];
}
