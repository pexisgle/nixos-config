{ pkgs, ... }:

{
  # adw-gtk3 provides the light and dark Adwaita variants that GTK 3
  # applications and Electron apps look up by theme name.
  home.packages = [ pkgs.adw-gtk3 ];

  # GTK 4, libadwaita, Chromium, and Electron take the dark preference from
  # these keys. Without them the apps fall back to Adwaita light even while the
  # shell is dark.
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3-dark";
  };
}
