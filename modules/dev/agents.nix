{ inputs, ... }:

{
  imports = [ inputs.skills-nix.homeModules.default ];

  # ユーザーグローバルなエージェント指示（opencode / DSH などが参照）。
  home.file.".agents/AGENTS.md".source = ./agents/AGENTS.md;

  skills = {
    enable = true;
    install = [
      "cli/cli@gh"
      "netresearch/file-search-skill@file-search"
      "anthropics/skills@skill-creator"
      "github/awesome-copilot@git-commit"
    ];
  };
}
