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
    };
  };
}
