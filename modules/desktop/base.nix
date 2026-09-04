{ pkgs, ... }:

{
  # Dual-DE setup is intentional: Plasma is the default session, Niri is
  # available from the SDDM session chooser (DankMaterialShell runs on Niri).
  # Keep defaultSession in sync with the DE you actually log into daily.
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings = {
      General = {
        EnableHiDPI = true;
      };
    };
  };
  services.displayManager.defaultSession = "plasma";
  programs.niri.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # KDE portal is the default so Plasma file choosers work; Niri sessions
  # fall back through xdg-desktop-portal-wlr/gnome as needed. If Niri becomes
  # the daily driver, switch default to wlr or gtk.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.common.default = "kde";
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    # Required for Wayland KMS capture; omit for Xorg-only setups.
    # openFirewall covers Sunshine ports; the explicit 47989-47990 TCP entries
    # in modules/core/network.nix are kept for documentation/VNC overlap.
    capSysAdmin = true;
    openFirewall = true;
  };

  # Needed for Sunshine virtual input and other user-space input emulation.
  hardware.uinput.enable = true;

  environment.systemPackages = with pkgs; [
    dbus
    pavucontrol
  ];
}
