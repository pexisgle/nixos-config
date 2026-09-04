{ ... }:

{
  programs.dank-material-shell = {
    enable = true;
    enableSystemMonitoring = true;
    settings = {
      syncModeWithPortal = true;
      terminalsAlwaysDark = true;
    };
    session = {
      isLightMode = false;
    };
    niri = {
      enableKeybinds = false;
      enableSpawn = true;
    };
  };
}
