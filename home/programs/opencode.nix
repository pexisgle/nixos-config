{ ... }:

{
  programs.opencode = {
    enable = true;
    settings = {
      plugin = [
        "@tarquinen/opencode-dcp@latest"
      ];
    };
  };

  home.file.".config/opencode/plugins/rtk.ts".source = ./opencode/plugins/rtk.ts;
}
