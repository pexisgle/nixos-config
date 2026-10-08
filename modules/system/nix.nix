# Nix daemon / store settings.
# Binary caches themselves live in modules/system/caches.nix (shared with flake nixConfig).
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

    # Download / build throughput: high parallelism assumes a fast link.
    # Lower these on metered or slow networks.
    max-substitution-jobs = 64;
    http-connections = 150;
    download-buffer-size = 52428800;
    max-jobs = "auto";
    cores = 0;

    # Keep 10-30 GiB free around GC so large closures (ROCm, kernels)
    # never fill the root filesystem mid-rebuild.
    min-free = 10737418240; # 10 GiB
    max-free = 32212254720; # 30 GiB

    substituters = [ caches.nixosSubstituter ] ++ caches.extraSubstituters;
    trusted-public-keys = [ caches.nixosTrustedPublicKey ] ++ caches.extraTrustedPublicKeys;
    # Only caches we control or explicitly trust may serve store paths.
    trusted-substituters = caches.extraSubstituters;
  };

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  # Garbage collection and generation cleanup are handled by programs.nh.clean
  # in modules/system/nh.nix (keeping recent generations and freeing unreferenced store paths).

  system.stateVersion = "26.05";
}
