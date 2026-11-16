{ ... }:

{
  programs.noctalia = {
    enable = true;
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Noctalia";
        # Built-in templates render the palette into GTK and Qt config.
        # Noctalia writes the GNOME color-scheme preference only while a
        # template set is applied, so apps stay light without these.
        templates = {
          enable_builtin_templates = true;
          builtin_ids = [
            "gtk3"
            "gtk4"
            "qt"
          ];
        };
      };
      shell = {
        font_family = "Noto Sans CJK JP";
        lang = "ja";
        # Noctalia runs as a systemd service, so apps launched from it must not
        # be killed when that service restarts.
        launch_apps_as_systemd_services = true;
        # Typing in the overview searches, and picking a result closes it, like
        # typing after opening the Start menu.
        umbriel_overview_type_to_launch_enabled = true;
        umbriel_overview_close_on_launch_enabled = true;
      };
      # Windows-like taskbar along the bottom edge: launcher on the left, one
      # icon per open window. Clicking an icon focuses or minimizes the window.
      bar.default = {
        position = "bottom";
        margin_ends = 0;
        start = [
          "launcher"
          "taskbar"
        ];
        center = [ "clock" ];
        end = [
          "media"
          "tray"
          "notifications"
          "clipboard"
          "network"
          "bluetooth"
          "volume"
          "brightness"
          "battery"
          "control-center"
          "session"
        ];
      };
    };
  };
}
