{ ... }:

{
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings.General.Privacy = "disabled";
  services.blueman.enable = true;
  networking.firewall.allowedTCPPorts = [
    3389
    5900
    47989
    47990
  ];
}
