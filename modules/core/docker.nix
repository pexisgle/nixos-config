{ ... }:

{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      bip = "192.168.123.1/24";
    };
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
}
