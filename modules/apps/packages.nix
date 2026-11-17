{ pkgs, ... }:

{
  home.packages = with pkgs; [
    floorp-bin
    google-chrome

    vesktop
    slack

    vlc
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
