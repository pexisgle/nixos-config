{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.opencode = {
    enable = true;
    settings = {
      plugin = [
        "openslimedit@latest"
      ];
      # GitHub MCP still runs via npx: nixpkgs has no stable
      # mcp-server-github attr to pin yet (upstream-first evaluated).
      # Re-check on nixpkgs bumps; when available, replace command with
      # "${pkgs.mcp-server-github}/bin/mcp-server-github".
      mcp.github = {
        type = "local";
        command = [
          "${pkgs.writeShellScript "opencode-github-mcp" ''
            set -eu
            token_file="${config.sops.secrets.github_token.path}"
            if [ ! -r "$token_file" ]; then
              echo "opencode-github-mcp: sops secret not readable: $token_file" >&2
              exit 1
            fi
            TOKEN="$(${pkgs.coreutils}/bin/cat "$token_file")"
            export GITHUB_TOKEN="$TOKEN"
            export GITHUB_PERSONAL_ACCESS_TOKEN="$TOKEN"
            # NOTE: impure network fetch on first run; pinned by lockfile when present.
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
