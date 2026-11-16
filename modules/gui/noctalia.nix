{ ... }:

{
  programs.noctalia = {
    enable = true;
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Noctalia";
      };
      shell = {
        font_family = "Noto Sans CJK JP";
        lang = "ja";
        # Noctalia runs as a systemd service, so apps launched from it must not
        # be killed when that service restarts.
        launch_apps_as_systemd_services = true;
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
