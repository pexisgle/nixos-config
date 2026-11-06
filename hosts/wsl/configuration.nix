{
  config,
  lib,
  pkgs,
  ...
}:

{
  wsl.enable = true;
  wsl.defaultUser = "pexisgle";

  wsl.wslConf.fileServer.enabled = true;

  users.users.pexisgle = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLj8DToaUoS+MZXdMj4mR3bphVk/1HEkUAge5u8ctIz"
    ];
  };

  services.openssh = {
    enable = true;
    ports = [
      22
      2222
    ];
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  fileSystems."/mnt/physical-nixos" = {
    device = "/dev/disk/by-uuid/a7cffbc2-4981-4da9-a86e-b04e8529464d";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  environment.shellInit = ''
    if ! /run/current-system/sw/bin/mountpoint -q /mnt/physical-nixos 2>/dev/null; then
      if [ -x /mnt/c/Windows/System32/schtasks.exe ]; then
        /mnt/c/Windows/System32/schtasks.exe /run /tn WSL_Mount_NixOS >/dev/null 2>&1
        for _i in $(seq 1 30); do
          if /run/current-system/sw/bin/mountpoint -q /mnt/physical-nixos 2>/dev/null; then
            break
          fi
          sleep 0.1
        done
      fi
    fi
  '';

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    git
    mise
    gh
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
    ];
  };

  programs.bash.interactiveShellInit = ''
    eval "$(mise activate bash)"
  '';

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  nix.settings.auto-optimise-store = true;

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep 3 --keep-since 3d";
      dates = "daily";
    };
    flake = "/home/pexisgle/nixos-config";
  };

  documentation.enable = false;
  documentation.man.enable = false;
  documentation.doc.enable = false;
  documentation.info.enable = false;

  system.stateVersion = "26.11";
}
