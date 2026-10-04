{
  pkgs,
  lib,
  ...
}:

let
  # hazkey-server の genDefaultConfig() と同じ既定プロファイル。Zenzai の
  # バックエンドだけ GPU（llama.cpp の Vulkan デバイス名）を既定にする。
  # デバイスが利用できない場合は hazkey-server が CPU へフォールバックする。
  defaultProfile = {
    profileName = "Default";
    autoConvertMode = 3; # AUTO_CONVERT_FOR_MULTIPLE_CHARS
    auxTextMode = 3; # AUX_TEXT_SHOW_WHEN_CURSOR_NOT_AT_END
    suggestionListMode = 3; # SUGGESTION_LIST_SHOW_PREDICTIVE_RESULTS
    numSuggestions = 3;
    useRichSuggestion = false;
    numCandidatesPerPage = 9;
    useRichCandidates = false;
    useInputHistory = true;
    stopStoreNewHistory = false;
    specialConversionMode = {
      commaSeparatedNumber = true;
      mailDomain = true;
      calendar = true;
      time = true;
      romanTypography = true;
      unicodeCodepoint = true;
      hazkeyVersion = true;
      halfwidthKatakana = true;
      extendedEmoji = true;
    };
    enabledKeymaps = [
      {
        name = "Fullwidth Number";
        isBuiltIn = true;
        filename = "Fullwidth Number";
      }
      {
        name = "Fullwidth Symbol";
        isBuiltIn = true;
        filename = "Fullwidth Symbol";
      }
      {
        name = "Japanese Symbol";
        isBuiltIn = true;
        filename = "Japanese Symbol";
      }
      {
        name = "Fullwidth Space";
        isBuiltIn = true;
        filename = "Fullwidth Space";
      }
    ];
    enabledTables = [
      {
        name = "Romaji";
        isBuiltIn = true;
        filename = "Romaji";
      }
    ];
    submodeEntryPointChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    zenzaiBackendDeviceName = "Vulkan0";
    zenzaiEnable = true;
    zenzaiInferLimit = 10;
    zenzaiContextualMode = true;
    zenzaiProfile = "";
  };
in
{
  # Hazkey の Zenzai デバイスは ~/.config/hazkey/config.json で選ぶ（サーバー既定は
  # "CPU"）。未作成時のみ既定プロファイル + Vulkan0 をシードして GPU を既定にし、
  # 以後は hazkey-settings でのユーザー設定を尊重する。
  home.activation.hazkeyZenzaiVulkan = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cfg="$HOME/.config/hazkey/config.json"
    if [ ! -e "$cfg" ]; then
      ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/hazkey"
      ${pkgs.coreutils}/bin/install -m 600 \
        ${pkgs.writeText "hazkey-config.json" (builtins.toJSON [ defaultProfile ])} "$cfg"
      # 起動済みサーバーに新しい設定を読ませる（次回起動時にも読み込まれる）。
      ${pkgs.systemd}/bin/systemctl --user try-restart hazkey-server.service 2>/dev/null || true
    fi
  '';
}
