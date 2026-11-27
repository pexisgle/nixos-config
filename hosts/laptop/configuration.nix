{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pexisgle-laptop";

  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
