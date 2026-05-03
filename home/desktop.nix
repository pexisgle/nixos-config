{ ... }:

{
  imports = [
    ./common.nix
  ];

  home.packages = with pkgs; [
    wineWow64Packages.staging
    winetricks
    lutris
  ];
}
