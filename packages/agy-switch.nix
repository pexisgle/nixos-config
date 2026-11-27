{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  webkitgtk_4_1,
  libsoup_3,
  gtk3,
  glib,
  libGL,
  vulkan-loader,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "agy-switch";
  version = "4.10.18";

  # Prebuilt Tauri binary. The project ships no Linux source release with a
  # pinned toolchain, so the console tarball from the GitHub release is the
  # artifact to patch.
  src = fetchurl {
    url = "https://github.com/anglee0323/agy-switch/releases/download/v${finalAttrs.version}/agy-switch-${finalAttrs.version}-linux-amd64.tar.gz";
    hash = "sha256-EVfbC0fddsZLXwN1l6fb80/2xaYTcaxGq+o4VpGdkhk=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    webkitgtk_4_1
    libsoup_3
    gtk3
    glib
    libGL
    vulkan-loader
    stdenv.cc.cc.lib
  ];

  unpackPhase = "tar xzf $src";

  installPhase = ''
    mkdir -p $out/bin $out/share/doc/agy-switch
    install -m755 agy-switch $out/bin/agy-switch
    install -m644 LICENSE CLI.md README.txt $out/share/doc/agy-switch/
  '';

  # WebKitGTK loads the GL drivers at runtime, and its RUNPATH does not reach
  # them, so they go on LD_LIBRARY_PATH for the OAuth window.
  preFixup = ''
    wrapProgram $out/bin/agy-switch \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          vulkan-loader
          libGL
        ]
      }
  '';

  meta = {
    description = "Manage Antigravity accounts, quotas and local usage";
    homepage = "https://github.com/anglee0323/agy-switch";
    license = lib.licenses.cc-by-nc-sa-40;
    mainProgram = "agy-switch";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
