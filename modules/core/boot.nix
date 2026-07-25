{ pkgs, lib, ... }:

{
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    configurationLimit = 5;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # RDNA 4 (RX 9060 XT) display timing stability fixes
  boot.kernelParams = [
    "amdgpu.sg_display=0"
    "amdgpu.dcdebugmask=0x400"
  ];

  boot.loader.timeout = 5;

  environment.systemPackages = [ pkgs.sbctl ];
}
