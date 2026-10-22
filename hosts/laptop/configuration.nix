# Laptop-specific NixOS entrypoint.
# Shared NixOS modules are automatically applied via flake.nix (modules/nixos.nix).
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nixos/power.nix
  ];

  networking.hostName = "pexisgle-laptop";
}
