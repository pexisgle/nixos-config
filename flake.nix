{
  description = "Pexisgle's NixOS Flake Configuration";

  # Literal attrset on purpose: Nix reads nixConfig without evaluating the flake.
  # Keep in sync with modules/system/caches.nix (scripts/check-caches.sh).
  nixConfig = {
    extra-substituters = [
      "https://pexisgle.cachix.org"
      "https://cache.numtide.com"
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
      "https://lanzaboote.cachix.org"
      "https://quickshell.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "pexisgle.cachix.org-1:6IcVMm0m93b5M6O7aA4lN6/DhfxepMHeivvLeTd6Yko="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
      "quickshell.cachix.org-1:vBm3s5tZThc5KDLj6zhHVCMp8wX/AZJwle9wqdi81ts="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

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
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    antigravity-flake = {
      url = "github:Hy4ri/antigravity-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-hazkey = {
      url = "github:aster-void/nix-hazkey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    serena = {
      url = "github:oraios/serena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    skills-nix.url = "github:z1-0/skills-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      lanzaboote,
      sops-nix,
      antigravity-flake,
      llm-agents,
      ...
    }@inputs:
    let
      sopsPaths = {
        ageKeyFile = "/home/pexisgle/.config/sops/age/keys.txt";
      };
      customPackagesOverlay =
        final: prev:
        let
          nodeAddonApi = final.callPackage ./packages/node-addon-api.nix { };
        in
        {
          github-desktop-plus = final.callPackage ./packages/github-desktop-plus.nix { };
          opencodex = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}.opencodex;
          antigravity = inputs.antigravity-flake.packages.${final.stdenv.hostPlatform.system}.antigravity;
          chatgpt = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}.chatgpt.override {
            commandLineArgs = "--ozone-platform=wayland --enable-wayland-ime";
          };
          command-code = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}.command-code;
          mistral-vibe = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}.mistral-vibe;
          opencode2 = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}.opencode2;
          opencode2-desktop =
            inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}.opencode2-desktop;
          # Electron が system の glib/gobject を先に読み込み、sharp の prebuilt
          # libvips が内蔵する glib/gobject と衝突して画像デコードで SIGSEGV する。
          # sharp のネイティブアドオンだけ nixpkgs の libvips でビルドし直し、
          # glib/gobject をプロセス内で 1 コピーに揃える。
          dsh-unwrapped =
            (inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}.dsh).overrideAttrs
              (old: {
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
                  final.pkg-config
                  final.patchelf
                ];
                buildInputs = (old.buildInputs or [ ]) ++ [ final.vips ];
                postInstall = (old.postInstall or "") + ''
                  sharp="$out/lib/node_modules/@deepseek-ai/dsh/node_modules/sharp"
                  mkdir -p "$sharp/src/node_modules"
                  cp -r ${nodeAddonApi}/lib/node_modules/node-addon-api "$sharp/src/node_modules/node-addon-api"
                  chmod -R u+w "$sharp/src/node_modules/node-addon-api"
                  (
                    cd "$sharp/src"
                    export SHARP_FORCE_GLOBAL_LIBVIPS=1
                    export NODE_PATH="$out/lib/node_modules/@deepseek-ai/dsh/node_modules"
                    export PKG_CONFIG_PATH="${final.vips.dev}/lib/pkgconfig:${final.glib.dev}/lib/pkgconfig"
                    ${final.nodejs}/bin/node ${final.nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js rebuild --nodedir=${final.nodejs}
                  )
                  rm -rf "$sharp/src/node_modules"
                  addon="$(find "$sharp/src/build/Release" -maxdepth 1 -name 'sharp-*.node' -type f | head -n 1)"
                  ${final.patchelf}/bin/patchelf \
                    --set-rpath ${final.vips.out}/lib:${final.glib.out}/lib:${final.stdenv.cc.cc.lib}/lib:${final.stdenv.cc.libc}/lib \
                    "$addon"
                  # Keep only the addon; gyp intermediates keep node-addon-api and
                  # vips.dev in the runtime closure.
                  rm -rf "$sharp/src/build/Release/obj.target" "$sharp/src/build/Release/.deps" "$sharp/src/build/node_modules"
                  rm -f "$sharp/src/build/"*.mk "$sharp/src/build/"*.Makefile "$sharp/src/build/"Makefile \
                    "$sharp/src/build/config.gypi" "$sharp/src/build/Release/nothing.a"
                '';
              });
          dsh = final.callPackage ./packages/dsh.nix { };
          deepseek-harness = final.dsh;
          deepseek-harness-desktop = final.callPackage ./packages/deepseek-harness-desktop.nix { };
          dsh-desktop = final.deepseek-harness-desktop;
          serena = inputs.serena.packages.${final.stdenv.hostPlatform.system}.serena;
          strongswan = prev.strongswan.overrideAttrs (old: {
            configureFlags = old.configureFlags ++ [ "--enable-ikev1" ];
          });
        };

      mkHost =
        { hostName }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              inputs
              hostName
              sopsPaths
              ;
          };
          modules = [
            {
              nixpkgs.overlays = [ customPackagesOverlay ];
            }
            ./modules/nixos.nix
            (./hosts + "/${hostName}/configuration.nix")
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.backupFileExtension = "backup";
              home-manager.sharedModules = [
                sops-nix.homeManagerModules.sops
                ./modules/home.nix
              ];
              home-manager.users.pexisgle = import (./hosts + "/${hostName}/home.nix");
              home-manager.extraSpecialArgs = {
                inherit
                  inputs
                  hostName
                  sopsPaths
                  ;
                sopsFile = "${self}/secrets/common.yaml";
              };
            }
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.sops
          ];
        };
    in
    {
      formatter.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.writeShellApplication {
          name = "nixfmt";
          runtimeInputs = [
            pkgs.nixfmt
            pkgs.git
            pkgs.findutils
          ];
          text = ''
            has_files=0
            for arg in "$@"; do
              if [[ "$arg" != -* ]]; then
                has_files=1
                break
              fi
            done

            if [ "$has_files" -eq 0 ]; then
              mapfile -t files < <(git ls-files '*.nix' 2>/dev/null || find . -type f -name '*.nix')
              if [ "''${#files[@]}" -gt 0 ]; then
                exec nixfmt "$@" "''${files[@]}"
              fi
            else
              exec nixfmt "$@"
            fi
          '';
        };

      nixosConfigurations = {
        pexisgle-desktop = mkHost {
          hostName = "desktop";
        };

        pexisgle-laptop = mkHost {
          hostName = "laptop";
        };

        pexisgle-wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            inputs.nixos-wsl.nixosModules.default
            ./hosts/wsl/configuration.nix
          ];
        };
      };
    };
}
