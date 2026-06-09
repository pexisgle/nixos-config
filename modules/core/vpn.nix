{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    networkmanager-l2tp
    strongswan
    xl2tpd
  ];
  
  services.xl2tpd.enable = true;

  networking.networkmanager = {
    plugins = with pkgs; [
      networkmanager-l2tp
      networkmanager-strongswan
    ];
  };

  services.strongswan = {
    enable = true;
    secrets = [ "ipsec.d/ipsec.nm-l2tp.secrets" ];
  };
  
  environment.etc."strongswan.conf".text = "";
}
