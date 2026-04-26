{ pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    configurationLimit = 5;
  };


  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.timeout = 5;

  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Tokyo";

  i18n.defaultLocale = "ja_JP.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;
  programs.niri.enable = true;

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.caskaydia-cove
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  programs.zsh.enable = true;

  users.users.pexisgle = {
    description = "pexisgle";
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "networkmanager" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      tree
    ];
  };

  environment.systemPackages = with pkgs; [
    sbctl
    vim
    wget
    git
    kdePackages.fcitx5-configtool
  ];

  services.gnome.gnome-keyring.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d"; # 7日より前の世代を自動削除
  };
  
  system.stateVersion = "25.11";
}
