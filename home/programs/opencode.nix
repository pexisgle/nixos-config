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
      provider.explabs = {
        npm = "@ai-sdk/openai-compatible";
        name = "Experiential Labs";
        options = {
          baseURL = "https://api.experientiallabs.ai/v1";
        };
        models = {
          "qwen3.8-27b" = {
            name = "qwen3.8-27b";
            limit = {
              context = 1000000;
              output = 131072;
            };
            cost = {
              input = 0.32;
              output = 2.4;
            };
          };
          "deepseek-v4-flash" = {
            name = "deepseek-v4-flash";
            limit = {
              context = 1048576;
              output = 384000;
            };
            cost = {
              input = 0.042448;
              output = 0.084896;
            };
          };
          "gpt-5.6-luna" = {
            name = "gpt-5.6-luna";
            limit = {
              context = 1050000;
              output = 128000;
            };
            cost = {
              input = 0.2;
              output = 1.2;
            };
          };
          "gpt-6-astra" = {
            name = "gpt-6-astra";
            limit = {
              context = 1050000;
              output = 128000;
            };
            cost = {
              input = 10.0;
              output = 50.0;
            };
          };
          "claude-fable-5.1" = {
            name = "claude-fable-5.1";
            limit = {
              context = 1000000;
              output = 128000;
            };
            cost = {
              input = 10.0;
              output = 50.0;
            };
          };
        };
      };
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
