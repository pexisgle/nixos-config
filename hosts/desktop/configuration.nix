{
  lib,
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

  swapDevices = lib.mkForce [
    {
      device = "/swapfile";
      size = 16384;
    }
  ];
}
