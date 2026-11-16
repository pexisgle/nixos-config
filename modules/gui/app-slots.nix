# Ordered taskbar slots. The Mod+<n> keybinds read this list, and the taskbar
# pins the entries that carry a desktop id, so slot N is the Nth icon on the
# bar as long as every entry is pinned.
#
# The taskbar matches a pin by desktop-entry id against the window's app id.
# DeepSeek Harness reports "deepseek-harness-desktop" for "deepseek-harness",
# and GitHub Desktop reports "desktop-plus" for "github-desktop", so pinning
# them would leave a dimmed pin beside a separate running icon. They keep a
# slot and stay reachable by key, without a pin.
[
  {
    appId = "floorp";
    desktop = "floorp.desktop";
    command = "floorp";
  }
  {
    appId = "kitty";
    desktop = "kitty.desktop";
    command = "kitty";
  }
  {
    appId = "deepseek-harness-desktop";
    desktop = null;
    command = "deepseek-harness-desktop";
  }
  {
    appId = "desktop-plus";
    desktop = null;
    command = "github-desktop";
  }
]
