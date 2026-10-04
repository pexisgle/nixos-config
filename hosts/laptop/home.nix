# Laptop-only Home Manager settings; shared settings come from modules/home.nix.
{ ... }:

{
  imports = [
    ../../modules/home.nix
  ];
}
