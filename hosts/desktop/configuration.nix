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

  # Desktop-only swapfile; the generated hardware config sets swapDevices = [].
  swapDevices = lib.mkForce [
    {
      device = "/swapfile";
      size = 16384;
    }
  ];
}
