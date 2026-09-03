{ ... }:

{
  imports = [
    ./core/atd.nix
    ./core/boot.nix
    ./core/docker.nix
    ./core/nix.nix
    ./core/network.nix
    ./core/secrets.nix
    ./core/tmp.nix
    ./core/vpn.nix
    ./desktop/base.nix
    ./desktop/fonts.nix
    ./desktop/locale.nix
    ./gaming/steam.nix
    ./user/pexisgle.nix
  ];
}
