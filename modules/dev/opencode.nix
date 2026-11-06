{ pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    settings = {
      # npx until nixpkgs pins this MCP server.
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
