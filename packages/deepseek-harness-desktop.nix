{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "deepseek-harness-desktop";
  version = "0.3.8";

  src = fetchurl {
    url = "https://github.com/agent-earth/deepseek-harness-desktop/releases/download/v${version}/DeepSeek-Harness-Desktop-${version}-linux-x86_64.AppImage";
    hash = "sha256-S6ZB2yv8NQmuPeaVLW0Zz+v90iiV9LYn/wpKNXIR+3U=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 644 -D ${appimageContents}/deepseek-harness.desktop $out/share/applications/deepseek-harness.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/deepseek-harness.png $out/share/icons/hicolor/512x512/apps/deepseek-harness.png
    sed -i -E 's|Exec=AppRun --no-sandbox %U|Exec=deepseek-harness-desktop %U|g' $out/share/applications/deepseek-harness.desktop
    echo "Keywords=dsh;deepseek;harness;ai;agent;" >> $out/share/applications/deepseek-harness.desktop
    ln -s deepseek-harness-desktop $out/bin/dsh-desktop
  '';

  meta = with lib; {
    description = "Desktop shell for DeepSeek Harness";
    homepage = "https://github.com/agent-earth/deepseek-harness-desktop";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "deepseek-harness-desktop";
  };
}
