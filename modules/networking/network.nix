{ ... }:

{
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  # Some BLE peripherals fail to pair with LE privacy on; keep disabled only
  # while those devices are in use and re-enable otherwise.
  hardware.bluetooth.settings.General.Privacy = "disabled";
  services.blueman.enable = true;

  # No explicit ports here: the owning modules open what they need
  # (services.sunshine openFirewall on the desktop host, Steam remote play).
  # Services bind on all interfaces; restrict to LAN/VPN via firewall zones
  # if this machine is ever exposed directly to the internet.
}
