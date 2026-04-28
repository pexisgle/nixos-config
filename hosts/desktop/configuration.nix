{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pexisgle-desktop";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      config.hardware.nvidia.package
    ];
    extraPackages32 = [
      config.hardware.nvidia.package
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  environment.systemPackages = with pkgs; [
     vulkan-loader
     vulkan-headers
     vulkan-validation-layers
     vulkan-tools
  ];
}
