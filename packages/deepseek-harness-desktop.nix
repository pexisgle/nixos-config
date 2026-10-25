{
  lib,
  appimageTools,
  fetchurl,
  dsh-unwrapped,
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
    postExtract = ''
      # Point desktop backend to modern dsh-unwrapped (0.2.x)
      sed -i -E "s|resolveDshEntry\(\) \{|resolveDshEntry() { return '${dsh-unwrapped}/lib/node_modules/@deepseek-ai/dsh/lib/bin.js';|g" \
        $out/resources/app/src/dsh-service.js

      # In dsh 0.2.x, plugin market is built-in. Empty out legacy dshmarket patch to prevent version mismatch.
      echo "[]" > $out/resources/app/config/plugin-market.patch.yml
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version;
  contents = appimageContents;

  extraInstallCommands = ''
    install -m 644 -D ${appimageContents}/deepseek-harness.desktop $out/share/applications/deepseek-harness.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/deepseek-harness.png $out/share/icons/hicolor/512x512/apps/deepseek-harness.png
    sed -i -E 's|Exec=AppRun --no-sandbox %U|Exec=deepseek-harness-desktop %U|g' $out/share/applications/deepseek-harness.desktop
    echo "Keywords=dsh;deepseek;harness;ai;agent;" >> $out/share/applications/deepseek-harness.desktop
    ln -s deepseek-harness-desktop $out/bin/dsh-desktop
  '';

  meta = with lib; {
    description = "Desktop shell for DeepSeek Harness (bundled with latest dsh)";
    homepage = "https://github.com/agent-earth/deepseek-harness-desktop";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "deepseek-harness-desktop";
  };
}

