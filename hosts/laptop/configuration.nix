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

  
  services.xserver.videoDrivers = [ "amdgpu" ];
}
