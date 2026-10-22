# Laptop-specific Home Manager settings (displays, touchpads, keybindings).
{ ... }:

{
  programs.niri.settings = {
    # Laptop touchpad configuration example:
    # input.touchpad = {
    #   tap = true;
    #   natural-scroll = true;
    #   accel-speed = 0.2;
    # };

    # Laptop internal display (eDP-1) scale/layout example:
    # outputs."eDP-1" = {
    #   scale = 1.25;
    # };
  };
}
