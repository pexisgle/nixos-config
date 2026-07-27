{ lib, stdenv, fetchFromGitHub, nodejs, makeWrapper, bash }:

stdenv.mkDerivation {
  pname = "claude-auto-retry";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "cheapestinference";
    repo = "claude-auto-retry";
    rev = "v0.6.1";
    hash = "sha256-jUOynxylTMIplUKtBlSn5P89zBZ/wzAKMKSIwVJUu3w=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib/node_modules/claude-auto-retry
    cp -r bin src systemd launchd package.json $out/lib/node_modules/claude-auto-retry/

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/claude-auto-retry \
      --add-flags "$out/lib/node_modules/claude-auto-retry/bin/cli.js"

    substituteInPlace $out/lib/node_modules/claude-auto-retry/bin/tmux-status.sh \
      --replace-fail '#!/usr/bin/env bash' '#!${bash}/bin/bash'
    ln -s $out/lib/node_modules/claude-auto-retry/bin/tmux-status.sh $out/bin/claude-auto-retry-tmux-status
    chmod +x $out/bin/claude-auto-retry-tmux-status
  '';

  meta = with lib; {
    description = "Automatically retry Claude Code sessions on subscription rate limits";
    homepage = "https://github.com/cheapestinference/claude-auto-retry";
    license = licenses.mit;
    mainProgram = "claude-auto-retry";
    platforms = platforms.all;
  };
}
