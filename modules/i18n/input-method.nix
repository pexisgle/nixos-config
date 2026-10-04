{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nix-hazkey.nixosModules.hazkey
  ];

  # Hazkey (azooKey engine + Zenzai neural conversion model) is the sole
  # Japanese IME; fcitx5-hazkey is added automatically by this module.
  # Vulkan-enabled build so Zenzai can use the GPU (device selection lives in
  # ~/.config/hazkey/config.json; see modules/i18n/hazkey.nix).
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
