{ config, pkgs, lib, ... }:

{
  # opencode-go/muse-spark-1.3-contributor は Zen Go の /responses 専用モデルだが、
  # opencodex 2.40.0 の同梱レジストリは 1.2 までしか wire 既定を持たないため、
  # provider 全体の openai-chat のままだと /chat/completions に投げて 500 になる。
  # また上流は reasoning.effort=max を拒否する(400)ため ladder から max を外し、
  # max 要求は xhigh へクランプさせる。初回起動後の live config に冪等マージする。
  home.activation.opencodexMuseSpark13Wire = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cfg="$HOME/.opencodex/config.json"
    if [ -f "$cfg" ]; then
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq '
        if .providers?["opencode-go"] then
          .providers["opencode-go"].modelAdapters = ((.providers["opencode-go"].modelAdapters // {}) + {"muse-spark-1.3-contributor": "openai-responses"})
          | .providers["opencode-go"].modelReasoningEfforts = ((.providers["opencode-go"].modelReasoningEfforts // {}) + {"muse-spark-1.3-contributor": ["minimal", "low", "medium", "high", "xhigh"]})
          | .providers["opencode-go"].modelDefaultReasoningEfforts = ((.providers["opencode-go"].modelDefaultReasoningEfforts // {}) + {"muse-spark-1.3-contributor": "high"})
          | .providers["opencode-go"].modelContextWindows = ((.providers["opencode-go"].modelContextWindows // {}) + {"muse-spark-1.3-contributor": 1048576})
          | .providers["opencode-go"].modelInputModalities = ((.providers["opencode-go"].modelInputModalities // {}) + {"muse-spark-1.3-contributor": ["text", "image"]})
        else . end
      ' "$cfg" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$cfg"
      else
        rm -f "$tmp"
      fi
    fi
  '';

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
