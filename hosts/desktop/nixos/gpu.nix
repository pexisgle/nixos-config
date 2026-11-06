{ pkgs, ... }:

{
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr
    rocmPackages.clr.icd
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  # RDNA4 display timing workarounds (desktop-only).
  boot.kernelParams = [
    "amdgpu.sg_display=0"
    "amdgpu.dcdebugmask=0x400"
  ];

  environment.sessionVariables = {
    KWIN_DRM_NO_AMS = "1";
  };

  environment.systemPackages = with pkgs; [
    vulkan-loader
    vulkan-headers
    vulkan-validation-layers
    vulkan-tools
  ];

  programs.nix-ld.libraries = with pkgs; [
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
}
