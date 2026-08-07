{ config, pkgs, lib, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
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

  home.activation.makeSshConfigWritable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    sshConfig="$HOME/.ssh/config"
    if [ -L "$sshConfig" ]; then
      cp --remove-destination "$(readlink -f "$sshConfig")" "$sshConfig"
      chmod 600 "$sshConfig"
    fi
  '';
}
