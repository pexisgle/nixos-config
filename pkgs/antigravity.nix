{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  undmg,
  glibc,
  pkgs,
  makeDesktopItem,
  copyDesktopItems,
}:

let
  version = "2.0.1";
  buildId = "6566078776737792";

  sources = {
    x86_64-linux = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}-${buildId}/linux-x64/Antigravity.tar.gz";
      sha256 = "1az9h1ridka89198isgg7gg1fv6cd7d7iwj1g4sd5dk1d7sy29q7";
    };
    aarch64-linux = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}-${buildId}/linux-arm/Antigravity.tar.gz";
      sha256 = "16sx2zb7rap9q2s75lh76l5wp2rl5zdbfi8hlrlz6m59vp4nrxas";
    };
    x86_64-darwin = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}-${buildId}/darwin-x64/Antigravity.dmg";
      sha256 = "0ys5glxa2gnbjn678ihbd8pb1n8cvkm54c9c2ayncsxmk050cjyx";
    };
    aarch64-darwin = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}-${buildId}/darwin-arm/Antigravity.dmg";
      sha256 = "1lp3n6pik4hswj5daxdvc9wjlivw01bfmwr53jkh01jm2dkz2y18";
    };
  };
in
stdenv.mkDerivation {
  pname = "antigravity";
  inherit version;

  src = fetchurl {
    inherit (sources.${stdenv.hostPlatform.system} or (throw "antigravity: unsupported system ${stdenv.hostPlatform.system}")) url sha256;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    copyDesktopItems
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    undmg
  ];

  desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
    (makeDesktopItem {
      name = "antigravity";
      exec = "antigravity";
      icon = "antigravity";
      desktopName = "Antigravity";
      genericName = "Agentic Development Platform";
      comment = "Google's agentic development platform (Desktop/IDE)";
      categories = [ "Development" "Utility" ];
    })
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glibc
    stdenv.cc.cc.lib # provides libstdc++.so (glibcxx)
    # common electron deps
    pkgs.glib
    pkgs.nss
    pkgs.nspr
    pkgs.dbus
    pkgs.atk
    pkgs.cups
    pkgs.libdrm
    pkgs.gtk3
    pkgs.pango
    pkgs.cairo
    pkgs.libX11
    pkgs.libXcomposite
    pkgs.libXdamage
    pkgs.libXext
    pkgs.libXfixes
    pkgs.libXrandr
    pkgs.libxcb
    pkgs.mesa
    pkgs.alsa-lib
    pkgs.expat
  ];

  # Remove sourceRoot to use standard extraction
  # sourceRoot = if stdenv.hostPlatform.isLinux then "." else null;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    ${if stdenv.hostPlatform.isLinux then ''
      # Assuming the tarball contains a binary named 'Antigravity' or similar
      # It might also contain other resources. Just copying everything.
      mkdir -p $out/opt/antigravity
      cp -r * $out/opt/antigravity/
      mkdir -p $out/bin
      if [ -f "$out/opt/antigravity/Antigravity" ]; then
        ln -s $out/opt/antigravity/Antigravity $out/bin/antigravity
      elif [ -f "$out/opt/antigravity/antigravity" ]; then
        ln -s $out/opt/antigravity/antigravity $out/bin/antigravity
      fi
    '' else ''
      mkdir -p $out/Applications
      cp -r Antigravity.app $out/Applications/
      mkdir -p $out/bin
      ln -s $out/Applications/Antigravity.app/Contents/MacOS/Antigravity $out/bin/antigravity
    ''}

    runHook postInstall
  '';

  meta = {
    description = "Google's agentic development platform (Desktop/IDE)";
    homepage = "https://antigravity.google";
    license = lib.licenses.unfree;
    mainProgram = "antigravity";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}