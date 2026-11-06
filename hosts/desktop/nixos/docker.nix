{ ... }:

{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      bip = "10.203.0.1/24";
      default-address-pools = [
        {
          base = "10.203.0.0/16";
          size = 24;
        }
      ];
    };
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  users.users.pexisgle.extraGroups = [ "docker" ];
}
