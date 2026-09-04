{ ... }:

{
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  # Some BLE peripherals fail to pair with LE privacy on; keep disabled only
  # while those devices are in use and re-enable otherwise.
  hardware.bluetooth.settings.General.Privacy = "disabled";
  services.blueman.enable = true;

  # Explicitly opened TCP ports (services.sunshine.openFirewall and
  # services for Steam remote play open their own ports separately):
  # 3389 = RDP, 5900 = VNC, 47989-47990 = Sunshine/Moonlight streaming.
  # These bind on all interfaces; restrict to LAN/VPN via firewall zones
  # if this machine is ever exposed directly to the internet.
  networking.firewall.allowedTCPPorts = [
    3389
    5900
    47989
    47990
  ];
}
