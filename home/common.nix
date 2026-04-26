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

  home.sessionVariables = {
    XMODIFIERS = "@im=fcitx";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  home.packages = with pkgs; [
    gcr
    kitty
    xwayland-satellite
    nixd
    floorp-bin
    (appimageTools.wrapType2 rec {
      pname = "github-desktop-plus";
      version = "3.5.9.0";
      src = fetchurl {
        url = "https://github.com/pol-rivero/github-desktop-plus/releases/download/v${version}/GitHubDesktopPlus-v${version}-linux-x86_64.AppImage";
        hash = "sha256-AmhF6m1k2wucu4QvGJP2542fxajNYExk9w9kqNKH2XU=";
      };
    })
  ];

  xdg = {
  enable = true;
  
  # デスクトップエントリの設定
  desktopEntries.github-desktop-plus = {
    name = "GitHub Desktop Plus";
    genericName = "Git Client";
    exec = "github-desktop-plus %U";
    icon = "github-desktop-plus";
    terminal = false;
    type = "Application";
    categories = [ "Development" "RevisionControl" "Utility" ];
    mimeType = [ "x-scheme-handler/x-github-desktop-auth" ];
  };

  # MIMEタイプの紐付けを明示
  mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/x-github-desktop-auth" = [ "github-desktop-plus.desktop" ];
    };
  };
};

  home.file."Desktop/GitHub Desktop Plus.desktop" = {
    text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=GitHub Desktop Plus
      GenericName=Git Client
      Comment=Advanced GitHub Desktop fork for Linux
      Exec=github-desktop-plus %U
      Icon=github-desktop-plus
      Terminal=false
      MimeType=x-scheme-handler/x-github-desktop-auth;
      Categories=Development;RevisionControl;Utility;
    '';
    executable = true;
  };

  programs.home-manager.enable = true;

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      yzhang.markdown-all-in-one
      jnoortheen.nix-ide
    ];
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
