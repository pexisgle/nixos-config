{ pkgs, lib, ... }:

{
  systemd.user.services.opencodex-proxy = {
    Unit = {
      Description = "OpenCodex Proxy Server";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.writeShellScript "opencodex-proxy-start" ''
        if [ -f "$HOME/.opencodex/service-api-token" ]; then
          OPENCODEX_API_AUTH_TOKEN="$(cat "$HOME/.opencodex/service-api-token")"
          export OPENCODEX_API_AUTH_TOKEN
        fi
        exec ${pkgs.bun}/bin/bun ${pkgs.opencodex}/lib/node_modules/@bitkyc08/opencodex/src/cli/index.ts start --port 10100
      ''}";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = [
        "OCX_SERVICE=1"
        "OCX_BUN_RUNTIME_SOURCE=override"
        "OCX_BUN_RUNTIME_PATH=${pkgs.bun}/bin/bun"
        "PATH=${lib.makeBinPath [ pkgs.nodejs pkgs.bun pkgs.coreutils pkgs.procps ]}"
      ];
      StandardOutput = "append:%h/.opencodex/service.log";
      StandardError = "append:%h/.opencodex/service.log";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
