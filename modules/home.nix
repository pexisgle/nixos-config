# Home Manager 側の共有モジュール入口 + グローバル設定。
# どのファイルが Home Manager 用かは、この import 一覧を唯一の真実とする。
{
  pkgs,
  inputs,
  sopsFile,
  sopsPaths,
  ...
}:

{
  imports = [
    inputs.niri.homeModules.niri
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    # apps
    ./apps/browsers.nix
    ./apps/communication.nix
    ./apps/media.nix
    # desktop
    ./desktop/dms.nix
    ./desktop/niri.nix
    ./desktop/xdg.nix
    # dev
    ./dev/opencode.nix
    ./dev/opencodex.nix
    ./dev/shell.nix
    ./dev/tools.nix
    ./dev/vscode.nix
    # i18n
    ./i18n/hazkey.nix
    # networking
    ./networking/ssh.nix
  ];

  home.username = "pexisgle";
  home.homeDirectory = "/home/pexisgle";
  home.stateVersion = "26.05";
  home.packages = with pkgs; [
    kicad
    godot
    unityhub
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
    # mise shims fallback for non-interactive shells (opencode/VSCode/tasks).
    # Interactive shells use `mise activate` hook from programs.mise; shims
    # ensure `node`/`pnpm` resolve even without the hook. mise prepends its
    # tool paths ahead of nixpkgs nodejs when the hook is active.
    "$HOME/.local/share/mise/shims"
  ];

  programs.home-manager.enable = true;
}
