{
  pkgs,
  lib,
  ...
}:

{
  systemd.user.services.opencodex-proxy = {
    Unit = {
      Description = "OpenCodex Proxy Server";
      After = [
        "network-online.target"
        "nss-lookup.target"
      ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      # A DNS flap at login makes the first model discovery stick; wait bounded.
      Type = "simple";
      ExecStartPre = "${pkgs.writeShellScript "opencodex-wait-dns" ''
        set -u
        NODE=${pkgs.nodejs}/bin/node
        for _ in $(${pkgs.coreutils}/bin/seq 1 15); do
          if "$NODE" -e "require('node:dns').promises.lookup('opencode.ai').then(()=>process.exit(0),()=>process.exit(1))" >/dev/null 2>&1 \
            && "$NODE" -e "require('node:dns').promises.lookup('token-plan.ap-southeast-1.maas.aliyuncs.com').then(()=>process.exit(0),()=>process.exit(1))" >/dev/null 2>&1; then
            exit 0
          fi
          ${pkgs.coreutils}/bin/sleep 2
        done
        exit 0
      ''}";
      ExecStart = "${pkgs.writeShellScript "opencodex-proxy-start" ''
        if [ -f "$HOME/.opencodex/service-api-token" ]; then
          OPENCODEX_API_AUTH_TOKEN="$(cat "$HOME/.opencodex/service-api-token")"
          export OPENCODEX_API_AUTH_TOKEN
        fi
        # llm-agents.nix の opencodex は bun + src/cli/index.ts を exec する
        # ラッパーなので、内部レイアウトに依存せず ocx を直接起動する。
        exec ${pkgs.opencodex}/bin/ocx start --port 10100
      ''}";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = [
        "OCX_SERVICE=1"
        "OCX_BUN_RUNTIME_SOURCE=override"
        "OCX_BUN_RUNTIME_PATH=${pkgs.bun}/bin/bun"
        "PATH=${
          lib.makeBinPath [
            pkgs.nodejs
            pkgs.bun
            pkgs.coreutils
            pkgs.procps
          ]
        }"
      ];
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "opencodex-proxy";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
