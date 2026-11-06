{
  config,
  lib,
  pkgs,
  ...
}:

let
  mainConfig = pkgs.writeText "ssh-config-main" ''
    Include ~/.ssh/config.d/*
  '';

  hmHosts = pkgs.writeText "ssh-config-hm-hosts" ''
    Host mail
      HostName 140.245.89.226
      User ubuntu
      IdentityFile ~/.ssh/ssh-key-2026-07-13.key

    Host sol
      HostName sol.cc.uec.ac.jp
      User s2611114

    Host ced
      HostName orange01.ced.cei.uec.ac.jp
      User s2611114
      ProxyJump sol
      ServerAliveInterval 60

    Host orange*
      HostName %h.ced.cei.uec.ac.jp
      User s2611114
      ProxyJump sol
      ServerAliveInterval 60

    Host ced* !ced
      User s2611114
      ProxyCommand ssh -q -W $(echo %h | sed -E 's/^ced-?(orange)?/orange/').ced.cei.uec.ac.jp:22 sol
      ServerAliveInterval 60

    Host rpi
      HostName rpi.pexisgle.dev
      User pexisgle
      ProxyCommand ${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h
  '';
in
{
  home.activation.sshConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -d -m 700 "$HOME/.ssh" "$HOME/.ssh/config.d"
    run install -Dm 600 -- "${mainConfig}" "$HOME/.ssh/config"
    run install -Dm 600 -- "${hmHosts}" "$HOME/.ssh/config.d/10-hm-hosts.conf"
  '';

  home.packages = [
    pkgs.cloudflared
  ];

  home.file.".ssh/config.d/.keep".text = "";
}
