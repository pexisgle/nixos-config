{ pkgs, ... }:

{
  programs.zsh.enable = true;

  users.users.pexisgle = {
    description = "pexisgle";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "networkmanager"
      "uinput"
      "docker"
      "render"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      tree
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    nil
    pkg-config
    openssl.dev
  ];
}
