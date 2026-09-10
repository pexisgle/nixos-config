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

    Host rpi
      HostName rpi.pexisgle.dev
      User pexisgle
      ProxyCommand ${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h
  '';
in
{
  # OpenSSH refuses config files that are not regular files owned by the
  # invoking user or that have loose permissions ("Bad owner or permissions").
  # This applies to files pulled in via Include as well as the main ~/.ssh/config.
  # Home Manager's home.file deploys files as store-symlinks, so we materialize
  # both the main config and hm-hosts as user-owned 0600 files via activation.
  home.activation.sshConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -d -m 700 "$HOME/.ssh" "$HOME/.ssh/config.d"
    run install -Dm 600 -- "${mainConfig}" "$HOME/.ssh/config"
    run install -Dm 600 -- "${hmHosts}" "$HOME/.ssh/config.d/10-hm-hosts.conf"
  '';

  home.packages = [
    pkgs.cloudflared
  ];

  # Writable drop-in dir for imperative additions; ad-hoc hosts go in
  # ~/.ssh/config.d/* and are picked up by the main config's Include.
  home.file.".ssh/config.d/.keep".text = "";
}
