{ pkgs, inputs, ... }:

{
  programs.dank-material-shell = {
    enable = true;
    enableSystemMonitoring = true;
    dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
      includes = {
        override = true;
        originalFileName = "hm";
        filesToInclude = [
          "alttab"
          "binds"
          "colors"
          "cursor"
          "layout"
          "outputs"
          "windowrules"
        ];
      };
    };
  };
}
