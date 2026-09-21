{ config, pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    # V2-native config. Custom integrations:
    #   - rtk: local plugin, discovered from ~/.config/opencode/plugins (home.file below)
    #   - computeruse: open-computer-use MCP server (mcp.servers)
    #   - github: GitHub MCP server (mcp.servers)
    # The V1 `plugin` / `provider` / top-level `mcp.github` entries are retired:
    # openslimedit and the old rtk.ts do not run on the V2 plugin API.
    settings = {
      # GitHub MCP still runs via npx: nixpkgs has no stable
      # mcp-server-github attr to pin yet (upstream-first evaluated).
      # Re-check on nixpkgs bumps; when available, replace command with
      # "${pkgs.mcp-server-github}/bin/mcp-server-github".
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
        # open-computer-use is not in nixpkgs. It ships a static Linux binary
        # behind a Node launcher; `npx` fetches the pinned version on first
        # server start (impure network fetch, npm cache warms afterwards).
        command = [
          "${pkgs.nodejs}/bin/npx"
          "-y"
          "open-computer-use@0.3.5"
          "mcp"
        ];
      };
    };
  };


  home.file.".config/opencode/plugins/rtk.ts".source = ./opencode/plugins/rtk.ts;
}
