{ pkgs, lib, ... }:

{
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    # Boot menu entries kept; actual rollback depth is bounded by nix.gc
    # (--delete-older-than 3d in modules/core/nix.nix).
    configurationLimit = 5;
  };

  # Track latest stable kernel for new AMD firmware. If out-of-tree modules
  # (e.g. ZFS) break, pin to pkgs.linuxPackages here or per-host.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.timeout = 5;

  environment.systemPackages = [ pkgs.sbctl ];
}
