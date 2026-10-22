# Laptop-specific NixOS power management & hardware settings.
{ pkgs, ... }:

{
  # Utility for controlling backlight brightness (e.g. brightness keys, scripts).
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  # Power profiles daemon is enabled by default in modern NixOS.
  # If you prefer TLP instead of power-profiles-daemon, switch them here:
  # services.power-profiles-daemon.enable = false;
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  #     START_CHARGE_THRESH_BAT0 = 75;
  #     STOP_CHARGE_THRESH_BAT0 = 80;
  #   };
  # };

  # Lid close behavior customization (optional):
  # services.logind.settings = {
  #   Login = {
  #     HandleLidSwitch = "suspend";
  #     HandleLidSwitchExternalPower = "ignore";
  #   };
  # };
}
