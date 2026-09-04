{ config, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # Ad-hoc/manual hosts go in ~/.ssh/config.d/* (created below) so
    # Home Manager stays the source of truth for the hosts declared here.
    includes = [ "~/.ssh/config.d/*" ];
    settings = {
      "Host mail" = {
        HostName = "140.245.89.226";
        User = "ubuntu";
        IdentityFile = "~/.ssh/ssh-key-2026-07-13.key";
      };
      "Host sol" = {
        HostName = "sol.cc.uec.ac.jp";
        User = "s2611114";
      };

      "Host rpi" = {
        HostName = "rpi.pexisgle.dev";
        User = "pexisgle";
        ProxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
      };
    };
  };

  home.packages = [
    pkgs.cloudflared
  ];

  # Writable drop-in dir for imperative additions; the main config stays
  # a Home Manager symlink (no copy-back activation hack).
  home.file.".ssh/config.d/.keep".text = "";
}
