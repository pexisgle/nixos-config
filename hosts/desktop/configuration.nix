{ config, pkgs, lib, ... }:

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

  # Dual monitor flicker workaround for AMD KWin
  environment.sessionVariables = {
    KWIN_DRM_NO_AMS = "1";
  };

  swapDevices = lib.mkForce [ {
    device = "/swapfile";
    size = 16384;
  } ];
  
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

  services.open-webui = {
    enable = true;
    port = 11111;
    environment = {
      OPENAI_API_BASE_URLS = "http://127.0.0.1:8000/v1";
      OPENAI_API_KEYS = "dummy";
      ENABLE_OLLAMA_API = "False";
      WEBUI_AUTH = "False";
    };
  };
}
