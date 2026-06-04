{ inputs, ... }:

{
  programs.opencode = {
    enable = true;
    settings = {
      plugin = [
        "@tarquinen/opencode-dcp@latest"
      ];
    };
  };

  programs.agent-skills = {
    enable = true;
    sources.nix-skills = {
      input = "nix-skills";
      subdir = ".claude/skills";
    };
    sources.vercel-skills = {
      input = "vercel-skills";
      subdir = "skills";
    };
    sources.local-skills = {
      path = ../../skills;
    };
    skills.enable = [
      "nix-best-practices"
      "find-skills"
      "agent-skills-nix"
    ];
    targets.opencode.enable = true;
  };

  home.file.".config/opencode/plugins/rtk.ts".source = ./opencode/plugins/rtk.ts;
}
