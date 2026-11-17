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
    ./gui/noctalia.nix
    ./gui/theme.nix
    ./gui/umbriel.nix
    ./gui/xdg.nix
    ./dev/agents.nix
    ./dev/shell.nix
    ./dev/tools.nix
    ./i18n/hazkey.nix
    ./networking/ssh.nix
  ];

  home.username = "pexisgle";
  home.homeDirectory = "/home/pexisgle";
  home.stateVersion = "26.11";
  home.packages = with pkgs; [
    codex
    chatgpt
  ];

  sops = {
    age.keyFile = sopsPaths.ageKeyFile;
    defaultSopsFile = sopsFile;
  };

  # Shims so non-interactive shells (agent sessions, editor tasks) resolve mise tools.
  home.sessionPath = [
    "$HOME/.local/share/mise/shims"
  ];

  programs.home-manager.enable = true;
}
