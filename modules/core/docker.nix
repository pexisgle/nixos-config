{ ... }:

{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      # Keep both the default bridge and automatically created networks away
      # from common LAN ranges. Each project receives a /24 instead of a /16.
      # This is a reserved local convention, not a guarantee against every VPN/LAN.
      bip = "10.203.0.1/24";
      default-address-pools = [
        { base = "10.203.0.0/16"; size = 24; }
      ];
    };
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
}
