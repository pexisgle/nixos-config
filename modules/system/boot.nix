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

  environment.systemPackages = [ pkgs.sbctl ];
}
