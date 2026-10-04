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

  # Gaming performance daemon, used by Steam/Lutris when available.
  programs.gamemode.enable = true;

  # Needed for user-space input emulation (Steam Input virtual controllers,
  # Sunshine virtual input on the desktop host, etc.).
  hardware.uinput.enable = true;

  environment.systemPackages = with pkgs; [
    dbus
    pavucontrol
  ];
}
