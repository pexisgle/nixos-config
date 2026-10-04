{
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
    ./gaming.nix
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
