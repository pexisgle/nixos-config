# NixOS 側の共有モジュール入口。
# どのファイルが NixOS 用かは、この import 一覧を唯一の真実とする。
{ ... }:

{
  imports = [
    # system
    ./system/atd.nix
    ./system/boot.nix
    ./system/docker.nix
    ./system/nh.nix
    ./system/nix.nix
    ./system/secrets.nix
    ./system/tmp.nix
    ./system/users.nix
    # networking
    ./networking/network.nix
    ./networking/vpn.nix
    # i18n
    ./i18n/input-method.nix
    ./i18n/locale.nix
    # desktop environment
    ./desktop/fonts.nix
    ./desktop/session.nix
    # hardware
    ./hardware/amdgpu.nix
  ];
}
