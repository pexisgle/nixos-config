{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vlc
    gimp
    onlyoffice-desktopeditors
  ];
}
