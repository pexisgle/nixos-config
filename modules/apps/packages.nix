{ pkgs, ... }:

{
  home.packages = with pkgs; [
    floorp-bin
    google-chrome

    vesktop
    slack
    notion-app-enhanced

    vlc
    gimp
    onlyoffice-desktopeditors
  ];
}
