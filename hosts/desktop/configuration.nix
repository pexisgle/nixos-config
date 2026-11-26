{
  lib,
  pkgs,
  ...
}:

let
  # 3.0.2 misses the working I²C bus on this GPU's DP-to-HDMI path.
  # https://github.com/rockowitz/ddcutil/issues/653
  ddcutil =
    if lib.versionOlder pkgs.ddcutil.version "3.0.3" then
      pkgs.ddcutil.overrideAttrs {
        version = "3.0.3-dev";
        src = pkgs.fetchFromGitHub {
          owner = "rockowitz";
          repo = "ddcutil";
          rev = "d79b235e65a9cef7fa08b0bc198680ba428a95e0";
          hash = "sha256-a4tJtzA+SyrdwMsOwvhiq04HPiN+ct4x/vp0mftpLBM=";
        };
      }
    else
      pkgs.ddcutil;
in
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
  systemd.user.services.noctalia.path = [
    ddcutil
    pkgs.coreutils
  ];

  swapDevices = lib.mkForce [
    {
      device = "/swapfile";
      size = 16384;
    }
  ];
}
