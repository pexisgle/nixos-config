{ ... }:

# Shared NixOS module manifest: the single list to update.
{
  imports = [
    ./system/boot.nix
    ./system/nh.nix
    ./system/nix-ld.nix
    ./system/nix.nix
    ./system/secrets.nix
    ./system/tmp.nix
    ./system/users.nix
    ./networking/network.nix
    ./networking/vpn.nix
    ./i18n/input-method.nix
    ./i18n/locale.nix
    ./gui/fonts.nix
    ./gui/session.nix
    ./hardware/amdgpu.nix
  ];
}
