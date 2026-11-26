{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./nixos/gpu.nix
    ./nixos/gaming.nix
    ./nixos/docker.nix
  ];

  networking.hostName = "pexisgle-desktop";

  # Noctalia uses DDC/CI over I²C for the external monitors.
  hardware.i2c.enable = true;
  systemd.user.services.noctalia.path = [ pkgs.ddcutil ];

  swapDevices = lib.mkForce [
    {
      device = "/swapfile";
      size = 16384;
    }
  ];
}
