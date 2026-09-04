{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pexisgle-desktop";

  # Base amdgpu setup comes from modules/hardware/amdgpu-base.nix.
  # This host only adds desktop-GPU extras (ROCm, Vulkan dev, RDNA4 quirks).
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr
    rocmPackages.clr.icd
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  # RDNA 4 (RX 9060 XT) display timing stability fixes.
  # Kept desktop-only: the laptop shares the amdgpu base but not this GPU quirk.
  boot.kernelParams = [
    "amdgpu.sg_display=0"
    "amdgpu.dcdebugmask=0x400"
  ];

  # Dual monitor flicker workaround for AMD KWin
  environment.sessionVariables = {
    KWIN_DRM_NO_AMS = "1";
  };

  swapDevices = lib.mkForce [
    {
      device = "/swapfile";
      size = 16384;
    }
  ];

  environment.systemPackages = with pkgs; [
    vulkan-loader
    vulkan-headers
    vulkan-validation-layers
    vulkan-tools
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      glib
      libx11
      rocmPackages.clr
      rocmPackages.rocm-smi
      rocmPackages.rocm-runtime
      rocmPackages.rocblas
      rocmPackages.hipblas
      numactl
      elfutils
      rocmPackages.rocprofiler-register
    ];
  };
}
