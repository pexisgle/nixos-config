{ ... }:

{
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  # LE privacy breaks pairing on some BLE peripherals; keep it off.
  hardware.bluetooth.settings.General.Privacy = "disabled";
  services.blueman.enable = true;

}
