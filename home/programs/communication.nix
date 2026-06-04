{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vesktop
    slack
    notion-app-enhanced
    github-desktop-plus
  ];
}
