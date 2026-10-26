{
  config,
  lib,
  pkgs,
  ...
}:

{
  # WSL の最小有効化設定
  wsl.enable = true;
  wsl.defaultUser = "pexisgle";

  # 起動エラー (0xd0000034) 対策を恒久化
  wsl.wslConf.fileServer.enabled = false;

  # ユーザー定義
  users.users.pexisgle = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    # WindowsからのSSH公開鍵を登録
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLj8DToaUoS+MZXdMj4mR3bphVk/1HEkUAge5u8ctIz"
    ];
  };

  # SSH サーバーの有効化
  services.openssh = {
    enable = true;
    ports = [
      22
      2222
    ]; # 標準22番と念のための2222番
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # 実機SSDのマウント設定
  fileSystems."/mnt/physical-nixos" = {
    device = "/dev/disk/by-uuid/a7cffbc2-4981-4da9-a86e-b04e8529464d";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  # 実機SSDのオンデマンド自動アタッチ (普通のwslコマンドやターミナル起動時に自動復旧)
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

  # Flakes と nix-command の有効化
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ==========================================
  # 開発ツール (git, direnv, mise)
  # ==========================================
  environment.systemPackages = with pkgs; [
    git
    mise
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ==========================================
  # 容量最小化・ディスク節約設定
  # ==========================================

  # 1. nix store の自動ハードリンク重複排除
  nix.settings.auto-optimise-store = true;

  # 2. nh による自動ガベージコレクション
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep 3 --keep-since 3d";
      dates = "daily";
    };
    flake = "/home/pexisgle/nixos-config";
  };

  # 3. マニュアル・ドキュメント類の除外（容量削減）
  documentation.enable = false;
  documentation.man.enable = false;
  documentation.doc.enable = false;
  documentation.info.enable = false;

  system.stateVersion = "26.05";
}
