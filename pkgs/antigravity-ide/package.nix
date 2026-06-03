{
  lib,
  stdenv,
  buildVscode,
  fetchurl,
  writeShellScript,
  coreutils,
  commandLineArgs ? "",
  useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin,
}:

let
  inherit (stdenv) hostPlatform;
  information = (lib.importJSON ../antigravity/information.json);
  source =
    information.sources."${hostPlatform.system}"
      or (throw "antigravity-ide: unsupported system ${hostPlatform.system}");
in
(buildVscode {
  inherit commandLineArgs useVSCodeRipgrep;
  inherit (information) version vscodeVersion;
  pname = "antigravity-ide";

  executableName = "antigravity-ide";
  sourceExecutableName = "antigravity";
  longName = "Antigravity IDE";
  shortName = "Antigravity IDE";
  libraryName = "antigravity";
  iconName = "antigravity";

  src = fetchurl { inherit (source) url sha256; };

  sourceRoot = if hostPlatform.isDarwin then "Antigravity.app" else "Antigravity";

  tests = { };
  updateScript = ../antigravity/update.js;

  customizeFHSEnv =
    args:
    args
    // {
      extraBwrapArgs = (args.extraBwrapArgs or [ ]) ++ [ "--tmpfs /opt/google/chrome" ];
      extraBuildCommands = (args.extraBuildCommands or "") + ''
        mkdir -p "$out/opt/google/chrome"
      '';
      runScript = writeShellScript "antigravity-ide-wrapper" ''
        for candidate in google-chrome-stable google-chrome chromium-browser chromium; do
          if target=$(command -v "$candidate"); then
            ${coreutils}/bin/ln -sf "$target" /opt/google/chrome/chrome
            break
          fi
        done
        exec ${args.runScript} "$@"
      '';
    };

  meta = {
    mainProgram = "antigravity-ide";
    description = "Agentic development platform, evolving the IDE into the agent-first era";
    homepage = "https://antigravity.google";
    downloadPage = "https://antigravity.google/download";
    changelog = "https://antigravity.google/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = with lib.maintainers; [
      xiaoxiangmoe
      Zaczero
    ];
  };
}).overrideAttrs (old: {
  postFixup = lib.replaceStrings
    [ "lib/antigravity/antigravity-ide" ]
    [ "lib/antigravity/antigravity" ]
    (old.postFixup or "");
})
