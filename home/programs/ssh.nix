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
  # OpenSSH refuses a main ~/.ssh/config that is not a regular file owned by
  # the invoking user ("Bad owner or permissions"), and Home Manager's
  # programs.ssh deploys it as a root-owned symlink into the Nix store.
  # ssh permission-checks only the main config, not files pulled in via
  # Include, so hosts live in a store-symlinked include under config.d/ and
  # the main config is materialized as a user-owned 0600 file by the
  # activation below.
  home.file.".ssh/config.d/10-hm-hosts.conf".source = hmHosts;

  home.activation.sshMainConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -Dm 600 -- "${mainConfig}" "$HOME/.ssh/config"
  '';

  home.packages = [
    pkgs.cloudflared
  ];

  # Writable drop-in dir for imperative additions; ad-hoc hosts go in
  # ~/.ssh/config.d/* and are picked up by the main config's Include.
  home.file.".ssh/config.d/.keep".text = "";
}
