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
	};

	outputs = { nixpkgs, home-manager, ... }@inputs:
		let
			githubDesktopPlusOverlay = final: prev: {
				github-desktop-plus = final.callPackage ./pkgs/github-desktop-plus.nix {};
			};

			mkHost = { hostName, homeModule }:
				nixpkgs.lib.nixosSystem {
					system = "x86_64-linux";
					specialArgs = {
						inherit inputs hostName;
					};
					modules = [
						{
							nixpkgs.overlays = [ githubDesktopPlusOverlay ];
						}
						./modules/common.nix
						(./hosts + "/${hostName}/configuration.nix")
						home-manager.nixosModules.home-manager
						{
							home-manager.useGlobalPkgs = true;
							home-manager.backupFileExtension = "backup";
							home-manager.users.pexisgle = import homeModule;
							home-manager.extraSpecialArgs = {
								inherit inputs hostName;
							};
						}
					];
				};
		in {
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

