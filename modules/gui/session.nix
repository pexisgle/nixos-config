{ pkgs, ... }:

{
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
  # Plasma is the default session; Niri and Umbriel are selectable at the login screen.
  services.displayManager.defaultSession = "plasma";
  programs.niri.enable = true;
  programs.umbriel.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # The shell runs as a systemd user service so it starts after Umbriel reports
  # readiness, and blocks XDG autostart apps until its tray host is up.
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    systemd.target = "umbriel-session.target";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.common.default = "kde";
  };

  environment.systemPackages = with pkgs; [
    dbus
    pavucontrol
  ];
}
