{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    moonlight-qt
  ];

  xdg.configFile."autostart/tailscale.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Tailscale
    Exec=${lib.getExe pkgs.tailscale} systray
  '';
}
