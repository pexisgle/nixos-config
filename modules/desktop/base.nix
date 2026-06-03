{ pkgs, ... }:

{
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;
  programs.niri.enable = true;
  services.gnome.gnome-keyring.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.common.default = "kde";
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    # Only required for Wayland KMS capture; omit for Xorg
    capSysAdmin = true;
    openFirewall = true;
  };

  # For older (pre-26.05) stable systems, enable the uinput kernel module
  hardware.uinput.enable = true;

  environment.systemPackages = with pkgs; [
    dbus
    pavucontrol
    vulkan-tools
  ];
}
