{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pexisgle-laptop";

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--operator=pexisgle" ];
  };
  # Apply the operator setting when switching an already running system.
  systemd.services.tailscaled-set.wantedBy = [ "multi-user.target" ];

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
