{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.niri.homeModules.niri
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];

  home.username = "pexisgle";
  home.homeDirectory = "/home/pexisgle";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    gcr
    kitty
    xwayland-satellite
    nixd
    gh
    github-desktop-plus
    floorp-bin
    vesktop
  ];


  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"         # also requires `programs.git.enable = true;`
      ];
      theme = "robbyrussell";
    };

  };

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      yzhang.markdown-all-in-one
      jnoortheen.nix-ide
    ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true; # zsh用のフックを有効化
    nix-direnv.enable = true;    # 高速化のための nix-direnv を有効化
  };

  programs.dank-material-shell = {
    enable = true;
    enableSystemMonitoring = true;
    dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
    niri = {
      # Keep DMS include-based keybinds only to avoid duplicated keybind sources.
      enableKeybinds = false;
      enableSpawn = true;
      includes = {
        override = true;
        originalFileName = "hm";
        filesToInclude = [
          "alttab"
          "binds"
          "colors"
          "cursor"
          "layout"
          "outputs"
          "windowrules"
        ];
      };
    };
  };
}
