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
	};

	outputs = { nixpkgs, home-manager, lanzaboote, ... }@inputs:
		let
			customPackagesOverlay = final: prev: {
				github-desktop-plus = final.callPackage ./pkgs/github-desktop-plus.nix {};
				antigravity = final.callPackage ./pkgs/antigravity.nix {};
				antigravity-cli = final.callPackage ./pkgs/antigravity-cli.nix {};
                                antigravity-ide = prev.antigravity.overrideAttrs (old: {
                                        pname = "antigravity-ide";
                                        postFixup = (old.postFixup or "") + ''
                                                mv $out/bin/antigravity $out/bin/antigravity-ide || true
                                                if [ -d $out/share/applications ]; then
                                                        for f in $out/share/applications/*.desktop; do
                                                                sed -i 's/Exec=antigravity/Exec=antigravity-ide/g' $f
                                                                sed -i 's/Name=Antigravity/Name=Antigravity IDE/g' $f
                                                                mv $f $out/share/applications/antigravity-ide.desktop || true
                                                        done
                                                fi
                                        '';
                                });
			};

			mkHost = { hostName, homeModule }:
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
							home-manager.users.pexisgle = import homeModule;
							home-manager.extraSpecialArgs = {
								inherit inputs hostName;
							};
						}
						lanzaboote.nixosModules.lanzaboote
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

