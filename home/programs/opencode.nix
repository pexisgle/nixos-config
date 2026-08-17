{ inputs, config, pkgs, lib, ... }:

{
  programs.opencode = {
    enable = true;
    settings = {
      plugin = [
        "openslimedit@latest"
      ];
      mcp.github = {
        type = "local";
        command = [
          "${pkgs.writeShellScript "opencode-github-mcp" ''
            TOKEN="$(${pkgs.coreutils}/bin/cat "${config.sops.secrets.github_token.path}")"
            export GITHUB_TOKEN="$TOKEN"
            export GITHUB_PERSONAL_ACCESS_TOKEN="$TOKEN"
            exec ${pkgs.nodejs}/bin/npx -y @modelcontextprotocol/server-github
          ''}"
        ];
      };
    };
  };

  programs.agent-skills = {
    enable = true;
    sources.vercel-skills = {
      input = "vercel-skills";
      subdir = "skills";
    };
    sources.local-skills = {
      path = ../../skills;
    };
    skills.enable = [
      "agent-skills-nix"
    ];
    targets.opencode.enable = true;
  };

  home.file.".config/opencode/plugins/rtk.ts".source = ./opencode/plugins/rtk.ts;
}
