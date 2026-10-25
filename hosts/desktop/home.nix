# Desktop-only Home Manager entrypoint.
# Shared Home Manager settings are automatically applied via flake.nix sharedModules (modules/home.nix).
{ ... }:

{
  imports = [
    ./home/gaming.nix
  ];
}
