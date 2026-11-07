{
  pkgs,
  inputs,
  sopsFile,
  sopsPaths,
  ...
}:

# Shared Home Manager module manifest: the single list to update.
{
  imports = [
    inputs.niri.homeModules.niri
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    ./apps/packages.nix
    ./gui/dms.nix
    ./gui/niri.nix
    ./gui/xdg.nix
    ./dev/agents.nix
    ./dev/opencode.nix
    ./dev/opencodex.nix
    ./dev/shell.nix
    ./dev/tools.nix
    ./dev/vscode.nix
    ./i18n/hazkey.nix
    ./networking/ssh.nix
  ];

  home.username = "pexisgle";
  home.homeDirectory = "/home/pexisgle";
  home.stateVersion = "26.11";
  home.packages = with pkgs; [
    kicad
    unityhub
    codex
    opencodex
    chatgpt
  ];

  home.sessionVariables = {
    KICAD10_SYMBOL_DIR = "${pkgs.kicad.libraries.symbols}/share/kicad/symbols";
    KICAD10_FOOTPRINT_DIR = "${pkgs.kicad.libraries.footprints}/share/kicad/footprints";
    KICAD10_TEMPLATE_DIR = "${pkgs.kicad.libraries.symbols}/share/kicad/template";
  };

  sops = {
    age.keyFile = sopsPaths.ageKeyFile;
    defaultSopsFile = sopsFile;
  };

  # Shims so non-interactive shells (opencode, VS Code tasks) resolve mise tools.
  home.sessionPath = [
    "$HOME/.local/share/mise/shims"
  ];

  programs.home-manager.enable = true;
}
