{
  lib,
  pkgs,
  ...
}:

let
  # Focus the Nth icon on the dock or the bar, following the order the shell
  # shows: pinned apps first, then one entry per running app. The shell owns
  # that order and the GUI can change it, so it is read at run time instead of
  # being restated here.
  slotScript = pkgs.writeShellApplication {
    name = "umbriel-slot";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnused
      pkgs.gtk3
      pkgs.jq
      pkgs.noctalia
      pkgs.umbriel
    ];
    text = ''
      if [ "$#" -ne 1 ]; then
        echo "usage: umbriel-slot <slot>" >&2
        exit 2
      fi

      # Both surfaces can be on screen; follow the dock when it is enabled.
      pin_path=widget.taskbar.pinned
      if [ "$(noctalia msg config-get dock.enabled 2>/dev/null | tr -d '[:space:]')" = "true" ]; then
        pin_path=dock.pinned
      fi

      mapfile -t ordered < <(
        noctalia msg config-get "$pin_path" 2>/dev/null \
          | tr -d "[]'" \
          | tr ',' '\n' \
          | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/\.desktop$//' \
          | sed '/^$/d'
      )

      windows=$(umbriel windows --json)
      mapfile -t running < <(
        jq -r 'reduce .[] as $w ([]; if index([$w.app_id]) then . else . + [$w.app_id] end) | .[]' <<<"$windows"
      )

      for id in ''${running[@]+"''${running[@]}"}; do
        seen=false
        for known in ''${ordered[@]+"''${ordered[@]}"}; do
          if [ "$known" = "$id" ]; then
            seen=true
            break
          fi
        done
        if [ "$seen" = false ]; then
          ordered+=("$id")
        fi
      done

      index=$(($1 - 1))
      if [ "$index" -lt 0 ] || [ "$index" -ge "''${#ordered[@]}" ]; then
        exit 0
      fi
      app=''${ordered[$index]}

      # A pinned desktop id can differ from the app id the window reports, so
      # fall back to a prefix match before treating the app as not running.
      ids=$(jq -r --arg app "$app" '.[] | select(.app_id == $app) | .id' <<<"$windows")
      if [ -z "$ids" ]; then
        ids=$(jq -r --arg app "$app" '.[] | select(.app_id | startswith($app)) | .id' <<<"$windows")
      fi

      if [ -z "$ids" ]; then
        exec gtk-launch "$app"
      fi

      # Take the window after the focused one, wrapping to the first, so the
      # same slot cycles an app that has several windows.
      focused=$(jq -r '.[] | select(.focused) | .id' <<<"$windows")
      target=""
      passed_focused=false
      while IFS= read -r id; do
        if [ "$passed_focused" = true ]; then
          target=$id
          break
        fi
        if [ "$id" = "$focused" ]; then
          passed_focused=true
        fi
      done <<<"$ids"

      if [ -z "$target" ]; then
        target=$(head -n1 <<<"$ids")
      fi

      # window-focus restores a minimized window too.
      umbriel msg window-focus "$target"
    '';
  };

  slotKeybinds = lib.listToAttrs (
    map (
      index:
      lib.nameValuePair "Mod+${toString index}" {
        action = "spawn ${lib.getExe slotScript} ${toString index}";
        repeat = false;
      }
    ) (lib.range 1 9)
  );

  # Umbriel ships no built-in keybinds; the packaged config.toml is the only
  # source of the default set. Including it and overriding only the keys we
  # change keeps the upstream defaults in sync with the package.
  raw = (pkgs.formats.toml { }).generate "umbriel-config.toml" {
    include.files = [ "${pkgs.umbriel}/share/umbriel/config.toml" ];

    general = {
      mod_key = "Super";
      autostart = [ "vesktop" ];
      # Raise and focus the window when an application asks for activation, so
      # a launched app never opens behind the current one.
      focus_on_activate = true;
    };

    input.keyboard.layout = "jp";

    # Floating windows moved by hand, like a conventional desktop, instead of
    # the scrolling tile layout Umbriel defaults to. Drop zones stay off so a
    # drag never tiles the window by surprise. A window's own maximize button
    # fills the usable area, without gaps or borders.
    layout = {
      mode = "stacking";
      stacking.drop_zones = false;
      client_maximize = "edges";
    };

    # Server-side title bars with minimize/maximize/close. "on" honours apps
    # that draw their own header bar, so they do not get a second one.
    appearance.title_bar = {
      mode = "on";
      height = 32;
      button_glyph = "always";
    };

    # Keep the browser's picture-in-picture window above other windows. Firefox
    # titles it in the UI language, so the packaged rule for the English title
    # does not match a localized one; match both and open it pinned. A pinned
    # window floats above the workspace and takes no focus, which is what the
    # always-on-top player should do.
    window_rule = [
      {
        match.title = "^(Picture-in-Picture|Picture in picture|ピクチャーインピクチャー)$";
        default_floating = true;
        default_pinned = true;
        default_position = {
          x = 20;
          y = 20;
          anchor = "bottom_right";
        };
      }
    ];

    # Electron reads the GTK theme at startup. Set it for the whole session so
    # apps come up dark even before the desktop portal reports the preference.
    environment = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      GTK_THEME = "adw-gtk3-dark";
      SDL_VIDEODRIVER = "wayland";
    };

    keybinds = slotKeybinds // {
      # Mod+<n> belongs to the taskbar now, so workspaces move to the chord
      # Windows uses for virtual desktops.
      "Mod+Ctrl+Left" = "workspace-previous";
      "Mod+Ctrl+Right" = "workspace-next";
      "Mod+D" = {
        action = "workspace-toggle-show-desktop";
        repeat = false;
      };

      # Moving a window between outputs replaces the tiling column moves, which
      # do nothing useful with floating windows.
      "Mod+Shift+Left" = "window-move-to-output-left";
      "Mod+Shift+Right" = "window-move-to-output-right";

      "Mod+S" = "spawn noctalia msg panel-toggle launcher";
      "Mod+A" = "spawn noctalia msg panel-toggle control-center";
      "Mod+V" = "spawn noctalia msg panel-toggle clipboard";
      "Mod+E" = {
        action = "spawn dolphin";
        repeat = false;
      };
      "Mod+I" = {
        action = "spawn noctalia msg settings-toggle";
        repeat = false;
      };
      "Mod+L" = {
        action = "spawn noctalia msg session lock";
        repeat = false;
      };
      "Mod+Tab" = {
        action = "overview-toggle";
        repeat = false;
      };

      "Print" = {
        action = "spawn noctalia msg screenshot-fullscreen --copy-to-clipboard";
        repeat = false;
      };
      "Mod+Shift+S" = {
        action = "spawn noctalia msg screenshot-region";
        repeat = false;
      };
      "Alt+F4" = {
        action = "window-close";
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
  validated =
    pkgs.runCommand "umbriel-config.toml"
      {
        nativeBuildInputs = [ pkgs.umbriel ];
        configFile = raw;
      }
      ''
        umbriel config validate -c "$configFile"
        cp "$configFile" $out
      '';
in
{
  xdg.configFile."umbriel/config.toml".source = validated;
}
