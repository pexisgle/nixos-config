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
  version = "2.0.6";
  buildId = "5413878570549248";

  sources = {
    x86_64-linux = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}-${buildId}/linux-x64/Antigravity.tar.gz";
      sha256 = "1iacwi4zpkdcp75hn0irrf4a7zaf1zafmc8f0ckprc29a59h87md";
    };
    aarch64-linux = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}-${buildId}/linux-arm/Antigravity.tar.gz";
      sha256 = "1aa55zdqi1hskrrqv2ndljkkxj769m8kp1a5p1rar0h5cm3pzz02";
    };
    x86_64-darwin = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}-${buildId}/darwin-x64/Antigravity.dmg";
      sha256 = "1w20vvfbxa0v1k59cja38gr6sxrqgamxzrlvnkcd9p76hv5f3xf6";
    };
    aarch64-darwin = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}-${buildId}/darwin-arm/Antigravity.dmg";
      sha256 = "17bax30xjmw3rc4pznxsjxym5rqr6dhmmr0khb4zpl833yrwabmz";
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