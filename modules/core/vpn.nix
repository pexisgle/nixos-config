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

  sops.secrets = {
    uec_vpn_psk = { };
    uec_vpn_user = { };
    uec_vpn_pass = { };
  };

  sops.templates."uec-vpn" = {
    content = builtins.replaceStrings
      [ "__PSK__" "__USER__" "__PASS__" ]
      [ config.sops.placeholder.uec_vpn_psk config.sops.placeholder.uec_vpn_user config.sops.placeholder.uec_vpn_pass ]
      ''
        [connection]
        id=UEC VPN
        type=vpn
        autoconnect=false

        [vpn]
        service-type=org.freedesktop.NetworkManager.l2tp
        gateway=vpn.cc.uec.ac.jp
        user=__USER__

        [vpn-secrets]
        ipsec-psk=__PSK__
        password=__PASS__

        [ipv4]
        method=auto

        [ipv6]
        method=disabled
      '';
    path = "/etc/NetworkManager/system-connections/UEC VPN.nmconnection";
    mode = "0600";
    owner = "root";
    group = "root";
  };
}
