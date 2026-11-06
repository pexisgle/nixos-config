# NixOS provides no /lib64/ld-linux-x86-64.so.2, so prebuilt binaries (mise
# node/python, AppImages, npm-distributed ELFs) cannot exec without this.
{ ... }:

{
  programs.nix-ld.enable = true;
}
