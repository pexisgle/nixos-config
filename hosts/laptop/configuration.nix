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

  # This machine has no swap, so the default HybridSleep cannot hibernate and
  # would leave the battery draining past critical. Power off instead.
  services.upower.criticalPowerAction = "PowerOff";

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
