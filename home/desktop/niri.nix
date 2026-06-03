{ ... }:

{
  programs.niri.settings = {
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
}
