{ ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    auto-optimise-store = true;

    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
      "https://lanzaboote.cachix.org"
      "https://quickshell.cachix.org"
      "https://devenv.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://hyprland.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
      "quickshell.cachix.org-1:vBm3s5tZThc5KDLj6zhHVCMp8wX/AZJwle9wqdi81ts="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];

    trusted-substituters = [
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
      "https://lanzaboote.cachix.org"
      "https://quickshell.cachix.org"
      "https://devenv.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://hyprland.cachix.org"
    ];
  };

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  system.stateVersion = "26.05";
}
