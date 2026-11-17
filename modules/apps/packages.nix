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

    nautilus
    loupe
    papers
    gnome-text-editor
    file-roller
    gnome-calculator
    mission-center
    baobab
    gnome-disk-utility
  ];
}
