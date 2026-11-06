{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nix-hazkey.nixosModules.hazkey
  ];

  services.hazkey = {
    enable = true;
    server.package =
      inputs.nix-hazkey.packages.${pkgs.stdenv.hostPlatform.system}.hazkey-server.override
        {
          enableVulkan = true;
        };
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
    ];
  };

  environment.systemPackages = [ pkgs.kdePackages.fcitx5-configtool ];
}
