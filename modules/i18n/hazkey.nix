{
  pkgs,
  lib,
  ...
}:

let
  defaultProfile = {
    profileName = "Default";
    autoConvertMode = 3;
    auxTextMode = 3;
    suggestionListMode = 3;
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
