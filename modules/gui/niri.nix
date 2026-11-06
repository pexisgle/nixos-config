{ pkgs, ... }:

{
  home.packages = [ pkgs.xwayland-satellite ];

  programs.niri = {
    package = pkgs.niri;
    settings = {
      input = {
        keyboard = {
          numlock = false;
          xkb = {
            layout = "jp";
          };
        };
      };
      "spawn-at-startup" = [
        { argv = [ "vesktop" ]; }
      ];
    };
  };
}
