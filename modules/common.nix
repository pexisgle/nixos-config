{ ... }:

{
  imports = [
    ./core/boot.nix
    ./core/docker.nix
    ./core/nix.nix
    ./core/network.nix
    ./desktop/base.nix
    ./desktop/fonts.nix
    ./desktop/locale.nix
    ./gaming/steam.nix
    ./user/pexisgle.nix
  ];
}
