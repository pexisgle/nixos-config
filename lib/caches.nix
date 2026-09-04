# Binary cache definitions for the NixOS side (modules/core/nix.nix).
#! Mirror of the literal lists in flake.nix nixConfig, which must stay literal
# (Nix reads it without full evaluation). Update both files together and run
# ./scripts/check-caches.sh to verify.
{
  # Cachix / upstream caches managed by this repo (without cache.nixos.org).
  # nixConfig extra-substituters are additive, so the official cache stays implicit there.
  extraSubstituters = [
    "https://pexisgle.cachix.org"
    "https://cache.numtide.com"
    "https://nix-community.cachix.org"
    "https://niri.cachix.org"
    "https://lanzaboote.cachix.org"
    "https://quickshell.cachix.org"
    "https://devenv.cachix.org"
    "https://nix-gaming.cachix.org"
    "https://hyprland.cachix.org"
  ];

  extraTrustedPublicKeys = [
    "pexisgle.cachix.org-1:6IcVMm0m93b5M6O7aA4lN6/DhfxepMHeivvLeTd6Yko="
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
    "quickshell.cachix.org-1:vBm3s5tZThc5KDLj6zhHVCMp8wX/AZJwle9wqdi81ts="
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  ];

  # Official cache, only needed for the NixOS-side full substituter list.
  nixosSubstituter = "https://cache.nixos.org/";
  nixosTrustedPublicKey = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
}
