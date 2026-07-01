{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pexisgle-desktop";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
      rocmPackages.clr.icd
    ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  
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
      # ROCm/HIP に必要なライブラリ群
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
