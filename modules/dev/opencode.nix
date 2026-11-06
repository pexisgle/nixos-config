{ config, pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    settings = {
      # npx until nixpkgs pins these MCP servers.
      mcp.servers.github = {
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
      mcp.servers.computeruse = {
        type = "local";
        command = [
          "${pkgs.nodejs}/bin/npx"
          "-y"
          "open-computer-use@0.3.5"
          "mcp"
        ];
      };

      providers.commandcode = {
        name = "Command Code";
        env = [ "COMMANDCODE_API_KEY" ];
        package = "@opencode/ai/providers/openai-compatible";
        settings.baseURL = "https://api.commandcode.ai/provider/v1";
      };

      providers.mimo = {
        name = "MiMo Token Plan";
        env = [ "MIMO_API_KEY" ];
        package = "@opencode/ai/providers/openai-compatible";
        settings.baseURL = "https://token-plan-sgp.xiaomimimo.com/v1";
        headers."api-key" = "{env:MIMO_API_KEY}";
      };
    };
  };

  home.file.".config/opencode/plugins/rtk.ts".source = ./opencode/plugins/rtk.ts;
  home.file.".config/opencode/plugins/model-discovery.ts".source =
    ./opencode/plugins/model-discovery.ts;
}
