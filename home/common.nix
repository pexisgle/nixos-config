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

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true;
    desktop = "$HOME/Desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    publicShare = "$HOME/Public";
    templates = "$HOME/Templates";
    videos = "$HOME/Videos";
  };

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"         
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
    enableZshIntegration = true; 
    nix-direnv.enable = true;    
  };

 programs.dank-material-shell = {
   enable = true;
   enableSystemMonitoring = true;
   dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
   settings = {
     syncModeWithPortal = true;
     terminalsAlwaysDark = true;
   };
   session = {
     isLightMode = false;
   };
   niri = {
     
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
