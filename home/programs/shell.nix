{ pkgs, ... }:

{
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

    # devenv may not be installed in minimal shells (e.g. CI); guard so
    # interactive startup never fails and non-interactive shells stay fast.
    initContent = ''
      if command -v devenv >/dev/null 2>&1; then
        eval "$(devenv hook zsh)"
      fi
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # mise: toolchain version pinning (node/pnpm via mikuec.com/mise.toml + .node-version).
  # programs.mise adds `eval "$(mise activate zsh)"` via zsh.initContent.
  # dev-tools.nix already installs the mise package; the module reuses pkgs.mise.
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };

  # Shell integrations for CLI tools installed in dev-tools.nix.
  # The packages themselves come from programs.* so hooks/completions stay wired.
  programs.fzf.enable = true;
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.bat.enable = true;
}
