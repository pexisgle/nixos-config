{ ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pexisgle-laptop";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Keep explicit driver selection to avoid pulling NVIDIA stack on laptop.
  services.xserver.videoDrivers = [ "amdgpu" ];
}
