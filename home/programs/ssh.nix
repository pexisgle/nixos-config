{ config, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "Host sol" = {
        HostName = "sol.cc.uec.ac.jp";
        User = "s2611114";
      };
    };
  };

  home.activation.sshConfig = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -L ~/.ssh/config ]; then
      rm ~/.ssh/config
    fi
    cp ${config.home.file.".ssh/config".source} ~/.ssh/config
    chmod 600 ~/.ssh/config
  '';
}
