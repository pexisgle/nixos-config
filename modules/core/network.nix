{ ... }:

{
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  networking.firewall.allowedTCPPorts = [ 3389 5900 47989 47990 ];
}