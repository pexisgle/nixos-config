# Laptop keeps only its hostname: amdgpu base comes from
# modules/hardware/amdgpu-base.nix via modules/common.nix.
# Add laptop-only deltas here (e.g. power management) when needed.
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pexisgle-laptop";
}
