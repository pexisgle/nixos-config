{
  lib,
  pkgs,
  ...
}:

let
  slots = import ./app-slots.nix;

  # Focus slot N, launching the app when it has no window. Pressing the same
  # slot again walks to the app's next window, the way a grouped taskbar icon
  # cycles.
  slotScript = pkgs.writeShellApplication {
    name = "umbriel-slot";
    runtimeInputs = [
      pkgs.umbriel
      pkgs.jq
    ];
    text = ''
      if [ "$#" -ne 1 ]; then
        echo "usage: umbriel-slot <slot>" >&2
        exit 2
      fi

      case "$1" in
      ${lib.concatStringsSep "\n" (
        lib.imap1 (index: slot: ''
          ${toString index})
            app=${lib.escapeShellArg slot.appId}
            command=${lib.escapeShellArg slot.command}
            ;;'') slots
      )}
        *)
          exit 0
          ;;
      esac

      windows=$(umbriel windows --json)
      ids=$(jq -r --arg app "$app" '[.[] | select(.app_id == $app)] | .[].id' <<<"$windows")
      focused=$(jq -r --arg app "$app" '.[] | select(.app_id == $app and .focused) | .id' <<<"$windows")

      if [ -z "$ids" ]; then
        exec "$command"
      fi

      # Take the window after the focused one, wrapping to the first.
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
    lib.imap1 (
      index: _:
      lib.nameValuePair "Mod+${toString index}" {
        action = "spawn ${lib.getExe slotScript} ${toString index}";
        repeat = false;
      }
    ) slots
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

    environment = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
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
