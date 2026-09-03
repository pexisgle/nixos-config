{ lib, stdenv, fetchzip, nodejs, bun, makeWrapper, importNpmLock, coreutils, util-linux }:

stdenv.mkDerivation {
  pname = "opencodex";
  version = "2.40.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/@bitkyc08/opencodex/-/opencodex-2.40.0.tgz";
    hash = "sha256-l1G0iwby6oFQNaHVvM3gdRT8T9Ph7VSySt9zMejHKfM=";
  };

  npmDeps = importNpmLock.buildNodeModules {
    npmRoot = ./opencodex;
    inherit nodejs;
    derivationArgs = {
      npmRebuildFlags = [ "--ignore-scripts" ];
    };
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/@bitkyc08/opencodex
    cp -r bin src gui assets README.md LICENSE package.json $out/lib/node_modules/@bitkyc08/opencodex/
    cp -r $npmDeps/node_modules $out/lib/node_modules/@bitkyc08/opencodex/

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/.ocx-real \
      --set OPENCODEX_BUN_PATH ${bun}/bin/bun \
      --prefix PATH : ${lib.makeBinPath [ nodejs bun ]} \
      --add-flags "$out/lib/node_modules/@bitkyc08/opencodex/bin/ocx.mjs"

    # opencodex refuses Codex config writes when /tmp is not root-owned
    # (src/codex/user-identity.ts: resolveTrustedPosixTmp). If the host /tmp
    # ever has unsafe ownership, transparently re-run the coordinator-writing
    # subcommands (sync/sync-cache) inside a private mount namespace with a
    # fresh root-owned /tmp, so `ocx sync` keeps working without manual
    # `unshare` workarounds. Catalog/config live under $HOME, so they persist;
    # only the ephemeral coordinator DB stays namespace-local.
    cat > $out/bin/ocx <<EOF
#!${stdenv.shell}
set -e
real="$out/bin/.ocx-real"
unshare="${util-linux}/bin/unshare"
stat="${coreutils}/bin/stat"
case "\''${1:-}" in
  sync|sync-cache) ;;
  *) exec "\$real" "\$@" ;;
esac
if [ -n "\$OCX_PRIVATE_TMP" ]; then
  exec "\$real" "\$@"
fi
tmp_uid=\$("\$stat" -c %u /tmp 2>/dev/null || echo 0)
if [ "\$tmp_uid" = "0" ]; then
  exec "\$real" "\$@"
fi
# Probe first so a missing/broken unshare falls back to the direct run and
# surfaces the upstream error instead of a new wrapper failure.
if "\$unshare" -rm --propagation private ${stdenv.shell} -c 'mount -t tmpfs tmpfs /tmp && chmod 1777 /tmp && chown root:root /tmp' 2>/dev/null; then
  export OCX_PRIVATE_TMP=1
  exec "\$unshare" -rm --propagation private ${stdenv.shell} -c 'mount -t tmpfs tmpfs /tmp && chmod 1777 /tmp && chown root:root /tmp && exec "\$0" "\$@"' "\$real" "\$@"
else
  exec "\$real" "\$@"
fi
EOF
    chmod +x $out/bin/ocx
    ln -s $out/bin/ocx $out/bin/opencodex

    runHook postInstall
  '';

  meta = with lib; {
    description = "Universal provider proxy for OpenAI Codex & Claude Code — use any LLM with Codex CLI, App, SDK, and Claude Code";
    homepage = "https://github.com/lidge-jun/opencodex";
    license = licenses.mit;
    mainProgram = "ocx";
    platforms = platforms.linux;
  };
}
