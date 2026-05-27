{ pkgs, ... }:

{
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;
  programs.niri.enable = true;
  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    dbus
    pavucontrol
    vulkan-tools
  ];
}