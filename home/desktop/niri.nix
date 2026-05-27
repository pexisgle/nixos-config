{ ... }:

{
  programs.niri.settings = {
    input = {
      keyboard = {
        xkb = {
          layout = "jp";
        };
      };
    };
    "spawn-at-startup" = [
      { argv = [ "vesktop" ]; }
    ];
  };
}