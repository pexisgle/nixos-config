{
  pkgs,
  config,
  inputs,
  sopsFile,
  sopsPaths ? import ../lib/sops.nix,
  ...
}:

{
  imports = [
    inputs.niri.homeModules.niri
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    ./desktop/material-shell.nix
    ./desktop/niri.nix
    ./desktop/xdg.nix
    ./programs/browsers.nix
    ./programs/communication.nix
    ./programs/dev-tools.nix
    ./programs/gaming.nix
    ./programs/media.nix
    ./programs/opencode.nix
    ./programs/opencodex.nix
    ./programs/ssh.nix
    ./programs/shell.nix
    ./programs/vscode.nix
  ];

  home.username = "pexisgle";
  home.homeDirectory = "/home/pexisgle";
  home.stateVersion = "26.05";
  home.packages = with pkgs; [
    kicad
    jan
    codex
    opencodex
    chatgpt
  ];

  # KiCad library paths track the packaged KiCad major version.
  # On a KiCad 11 bump these become KICAD11_* pointing at the same layout.
  home.sessionVariables = {
    KICAD10_SYMBOL_DIR = "${pkgs.kicad.libraries.symbols}/share/kicad/symbols";
    KICAD10_FOOTPRINT_DIR = "${pkgs.kicad.libraries.footprints}/share/kicad/footprints";
    KICAD10_TEMPLATE_DIR = "${pkgs.kicad.libraries.symbols}/share/kicad/template";
  };

  sops = {
    age.keyFile = sopsPaths.ageKeyFile;
    defaultSopsFile = sopsFile;
    secrets.github_token = { };
  };

  home.sessionPath = [
    "$HOME/.bun/bin"
    # mise shims fallback for non-interactive shells (opencode/VSCode/tasks).
    # Interactive shells use `mise activate` hook from programs.mise; shims
    # ensure `node`/`pnpm` resolve even without the hook. mise prepends its
    # tool paths ahead of nixpkgs nodejs when the hook is active.
    "$HOME/.local/share/mise/shims"
  ];

  programs.home-manager.enable = true;
}
