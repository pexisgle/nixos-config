{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nix-hazkey.nixosModules.hazkey
  ];

  time.timeZone = "Asia/Tokyo";
  time.hardwareClockInLocalTime = true;

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

  # Hazkey (azooKey engine + Zenzai neural conversion model)
  services.hazkey.enable = true;

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc-ut
      fcitx5-gtk
    ];
  };

  environment.systemPackages = [ pkgs.kdePackages.fcitx5-configtool ];
}
