{ config, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
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

  home.activation.sshConfig = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -L ~/.ssh/config ]; then
      rm ~/.ssh/config
    fi
    cp ${config.home.file.".ssh/config".source} ~/.ssh/config
    chmod 600 ~/.ssh/config
  '';
}
