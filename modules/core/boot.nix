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

  boot.loader.timeout = 5;

  environment.systemPackages = [ pkgs.sbctl ];
}
