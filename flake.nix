{
  description = "Pexisgle's NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.nixpkgs.follows = "nixpkgs";
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
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      lanzaboote,
      agent-skills,
      ...
    }@inputs:
    let
      customPackagesOverlay = final: prev: {
        appimageTools = prev.appimageTools // {
          wrapType2 = args: prev.appimageTools.wrapType2 (args // {
            extraPkgs = p: (args.extraPkgs or (p: [])) p ++ (with final; [
              numactl
              elfutils
              rocmPackages.rocprofiler-register
              rocmPackages.clr
              rocmPackages.rocblas
              rocmPackages.hipblas
              rocmPackages.rocminfo
            ]);
          });
        };

        github-desktop-plus = final.callPackage ./pkgs/github-desktop-plus.nix { };
        antigravity = final.callPackage ./pkgs/antigravity-hub/package.nix { };
        # antigravity-ide = (final.callPackage ./pkgs/antigravity-ide/package.nix { }).fhs;
        openldap = prev.openldap.overrideAttrs (old: {
          doCheck = false;
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
              ];
              home-manager.users.pexisgle = import homeModule;
              home-manager.extraSpecialArgs = {
                inherit inputs hostName;
              };
            }
            lanzaboote.nixosModules.lanzaboote
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
