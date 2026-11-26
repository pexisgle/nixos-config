{ pkgs, ... }:

let
  loginTheme = pkgs.sddm-astronaut.override {
    embeddedTheme = "purple_leaves";
    themeConfig = {
      Font = "Noto Sans CJK JP";
      Locale = "ja_JP";
      DateFormat = "M月d日 dddd";
      DateTextColor = "#e2e8fa";
      WarningColor = "#ffb4c2";
      BlurMax = "48";
      DimBackground = "0.25";
      DimBackgroundColor = "#12101e";
    };
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;
    enableHidpi = true;
    theme = "${loginTheme}/share/sddm/themes/sddm-astronaut-theme";
    extraPackages = [ loginTheme ];
  };
  services.displayManager.defaultSession = "umbriel";
  programs.umbriel.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # The shell runs as a systemd user service so it starts after Umbriel reports
  # readiness, and blocks XDG autostart apps until its tray host is up.
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    systemd.target = "umbriel-session.target";
  };

  xdg.portal = {
    enable = true;
    config.common.default = "gtk";

    # GTK and Electron apps read the appearance from the Settings interface to
    # decide dark mode. Route it to the GTK backend, which reads the GNOME
    # color-scheme preference, so applications follow the dark shell.
    config.umbriel = {
      default = [
        "umbriel"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Settings" = "gtk";
      "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
    };
  };

  # Nautilus resolves Trash, mounted media, and MTP devices through gvfs over
  # D-Bus, and gvfs lists drives through udisks2.
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    dbus
    pavucontrol
  ];
}
