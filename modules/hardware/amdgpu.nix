# Common AMD graphics base shared by desktop and laptop.
# Host-specific extras (ROCm, kernel params, Vulkan dev packages) stay in hosts/.
{ ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "amdgpu" ];
}
