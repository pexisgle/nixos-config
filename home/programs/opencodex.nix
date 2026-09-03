{ pkgs, lib, ... }:

{
  systemd.user.services.opencodex-proxy = {
    Unit = {
      Description = "OpenCodex Proxy Server";
      After = [ "network-online.target" "nss-lookup.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      # The proxy's first provider-model discovery runs at startup and a
      # failed lookup sticks (degraded catalog until restart). After
      # `nixos-rebuild switch` or login, DNS can flap briefly, so wait for
      # the provider hosts to resolve before starting. Bounded and always
      # exits 0: normal starts proceed immediately, flaps ride out ≤30s,
      # and boot/login never blocks on this. Uses node dns.lookup, the same
      # resolver stack opencodex itself uses.
      ExecStartPre = "${pkgs.writeShellScript "opencodex-wait-dns" ''
        for _ in $(seq 1 15); do
          if node -e "require('node:dns').promises.lookup('opencode.ai').then(()=>process.exit(0),()=>process.exit(1))" >/dev/null 2>&1 \
            && node -e "require('node:dns').promises.lookup('token-plan.ap-southeast-1.maas.aliyuncs.com').then(()=>process.exit(0),()=>process.exit(1))" >/dev/null 2>&1; then
            exit 0
          fi
          sleep 2
        done
        exit 0
      ''}";
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
