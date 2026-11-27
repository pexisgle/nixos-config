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
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    # mise の shim は PATH に居るが、グローバル既定が無いと `node` が
    # "No version is set for shim" で失敗する。Antigravity の GUI も
    # プラグイン (agy-fast / agy-powertools) の MCP サーバも PATH 上の
    # `node` を叩くため、既定を 1 か所で固定する。
    globalConfig.tools.node = "26";
  };

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
