{
  description = "Pexisgle's NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-skills = {
      url = "github:0xbigboss/claude-code";
      flake = false;
    };
    vercel-skills = {
      url = "github:vercel-labs/skills";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      lanzaboote,
      agent-skills,
      sops-nix,
      antigravity-nix,
      ...
    }@inputs:
    let
      customPackagesOverlay = final: prev: {
        github-desktop-plus = final.callPackage ./pkgs/github-desktop-plus.nix { };
        antigravity = inputs.antigravity-nix.packages.${final.system}.default;
        rtk = prev.rtk.overrideAttrs (oldAttrs: {
          env = (oldAttrs.env or { }) // {
            RUSTFLAGS = "--cap-lints allow";
          };
        });
      };

      mkHost =
        { hostName, homeModule }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs hostName;
          };
          modules = [
            {
              nixpkgs.overlays = [ customPackagesOverlay ];
            }
            ./modules/common.nix
            (./hosts + "/${hostName}/configuration.nix")
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.backupFileExtension = "backup";
              home-manager.sharedModules = [
                agent-skills.homeManagerModules.default
                sops-nix.homeManagerModules.sops
              ];
              home-manager.users.pexisgle = import homeModule;
              home-manager.extraSpecialArgs = {
                inherit inputs hostName;
                sopsFile = "${self}/secrets/common.yaml";
              };
            }
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.sops
          ];
        };
    in
    {
      nixosConfigurations = {
        pexisgle-desktop = mkHost {
          hostName = "desktop";
          homeModule = ./home/desktop.nix;
        };

        pexisgle-laptop = mkHost {
          hostName = "laptop";
          homeModule = ./home/laptop.nix;
        };
      };
    };
}
