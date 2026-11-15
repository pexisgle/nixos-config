{ pkgs, ... }:

let
  # Umbriel ships no built-in keybinds; the packaged config.toml is the only
  # source of the default set. Including it and overriding only the keys we
  # change keeps the upstream defaults in sync with the package.
  raw = (pkgs.formats.toml { }).generate "umbriel-config.toml" {
    include.files = [ "${pkgs.umbriel}/share/umbriel/config.toml" ];

    general = {
      mod_key = "Super";
      autostart = [ "vesktop" ];
    };

    input.keyboard.layout = "jp";

    environment = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      SDL_VIDEODRIVER = "wayland";
    };

    keybinds = {
      "Mod+S" = "spawn noctalia msg panel-toggle control-center";
      "Mod+V" = "spawn noctalia msg panel-toggle clipboard";
      "Mod+Shift+S" = {
        action = "spawn noctalia msg settings-toggle";
        repeat = false;
      };
      "Alt+Tab" = {
        action = "spawn noctalia msg window-switcher hold";
        repeat = false;
      };
      "Alt+Shift+Tab" = {
        action = "spawn noctalia msg window-switcher hold reverse";
        repeat = false;
      };
    };
  };

  # Catch config errors at build time instead of as a banner after login.
  validated = pkgs.runCommand "umbriel-config.toml" {
    nativeBuildInputs = [ pkgs.umbriel ];
    configFile = raw;
  } ''
    umbriel config validate -c "$configFile"
    cp "$configFile" $out
  '';
in
{
  xdg.configFile."umbriel/config.toml".source = validated;
}
