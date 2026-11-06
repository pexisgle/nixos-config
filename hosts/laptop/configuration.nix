{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pexisgle-laptop";

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
