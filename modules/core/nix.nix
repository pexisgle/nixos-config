# Nix daemon / store settings.
# Binary caches themselves live in lib/caches.nix (shared with flake nixConfig).
{
  caches ? import ../../lib/caches.nix,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-40.10.5"
  ];

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

  # Daily GC keeps the store bounded; generations older than 3 days are
  # collectable. lanzaboote keeps 5 bootloader entries independently,
  # so rollback depth is limited by GC here, not by configurationLimit alone.
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  system.stateVersion = "26.05";
}
