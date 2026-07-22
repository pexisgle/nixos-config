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
  };

  system.activationScripts.uec-vpn = lib.stringAfter [ "setupSecrets" ] ''
    mkdir -p /etc/NetworkManager/system-connections
    if [ -f /run/secrets/uec_vpn_psk ] && [ -f /run/secrets/uec_vpn_user ]; then
      ${pkgs.coreutils}/bin/cat > /etc/NetworkManager/system-connections/UEC-VPN.nmconnection << EOF
[connection]
id=UEC-VPN
type=vpn
autoconnect=false

[vpn]
service-type=org.freedesktop.NetworkManager.l2tp
gateway=vpn.cc.uec.ac.jp
user=$(cat /run/secrets/uec_vpn_user)
ipsec-enabled=yes
machine-auth-type=psk
password-flags=2

[vpn-secrets]
ipsec-psk=$(cat /run/secrets/uec_vpn_psk)

[ipv4]
method=auto

[ipv6]
method=disabled
EOF
      ${pkgs.coreutils}/bin/chmod 600 /etc/NetworkManager/system-connections/UEC-VPN.nmconnection
      ${pkgs.networkmanager}/bin/nmcli connection reload 2>/dev/null || true
    fi
  '';
}
