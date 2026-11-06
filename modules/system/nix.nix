{ ... }:

let
  # Module arguments cannot supply defaults, so import the mirror directly.
  caches = import ./caches.nix;
in
{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    auto-optimise-store = true;

    max-substitution-jobs = 64;
    http-connections = 150;
    download-buffer-size = 52428800;
    max-jobs = "auto";
    cores = 0;

    min-free = 10737418240; # 10 GiB
    max-free = 32212254720; # 30 GiB

    substituters = [ caches.nixosSubstituter ] ++ caches.extraSubstituters;
    trusted-public-keys = [ caches.nixosTrustedPublicKey ] ++ caches.extraTrustedPublicKeys;
    trusted-substituters = caches.extraSubstituters;
  };

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  system.stateVersion = "26.11";
}
