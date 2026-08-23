{ lib, stdenv, fetchzip, nodejs, bun, makeWrapper, importNpmLock }:

stdenv.mkDerivation {
  pname = "opencodex";
  version = "2.31.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/@bitkyc08/opencodex/-/opencodex-2.31.0.tgz";
    hash = "sha256-WlEtDVfKF0zYn9mgUFX4EXGwcjaE7IwAbLpOm6BLOko=";
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
    makeWrapper ${nodejs}/bin/node $out/bin/ocx \
      --set OPENCODEX_BUN_PATH ${bun}/bin/bun \
      --prefix PATH : ${lib.makeBinPath [ nodejs bun ]} \
      --add-flags "$out/lib/node_modules/@bitkyc08/opencodex/bin/ocx.mjs"
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
