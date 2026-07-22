{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    networkmanager-l2tp
    strongswan
    xl2tpd
  ];

  networking.networkmanager = {
    plugins = with pkgs; [
      networkmanager-l2tp
      networkmanager-strongswan
    ];
  };

  # Required so charon can start when launched by nm-l2tp-service
  # (which runs "ipsec restart --conf <custom>" without STRONGSWAN_CONF)
  environment.etc."strongswan.conf".text = ''
    charon {
      plugins {
        stroke {
          secrets_file = /etc/ipsec.secrets
        }
      }
    }
  '';

  sops.secrets = {
    uec_vpn_psk = { };
    uec_vpn_user = { };
    uec_vpn_pass = { };
  };

  sops.templates."uec-vpn-nmconnection" = {
    content = builtins.replaceStrings
      [ "__PSK__" "__USER__" "__PASS__" ]
      [ config.sops.placeholder.uec_vpn_psk config.sops.placeholder.uec_vpn_user config.sops.placeholder.uec_vpn_pass ]
      ''
        [connection]
        id=UEC-VPN
        type=vpn
        autoconnect=false

        [vpn]
        service-type=org.freedesktop.NetworkManager.l2tp
        gateway=vpn.cc.uec.ac.jp
        user=__USER__
        ipsec-enabled=yes
        machine-auth-type=psk
        password-flags=2

        [vpn-secrets]
        ipsec-psk=__PSK__
        password=__PASS__

        [ipv4]
        method=auto

        [ipv6]
        method=disabled
      '';
  };

  environment.etc."NetworkManager/system-connections/UEC-VPN.nmconnection" = {
    source = config.sops.templates."uec-vpn-nmconnection".path;
    mode = "0600";
  };
}
