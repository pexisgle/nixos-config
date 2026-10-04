{ pkgs, ... }:

{
  # Sunshine/Moonlight streaming host. Kept desktop-only: the laptop is not
  # used as a streaming target.
  services.sunshine = {
    enable = true;
    autoStart = true;
    # Required for Wayland KMS capture; omit for Xorg-only setups.
    # openFirewall handles every Sunshine port (TCP 47984-48010,
    # UDP 47998-48010).
    capSysAdmin = true;
    openFirewall = true;
  };

  # Steam is desktop-only as well; the laptop is not used for gaming.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [
      dwproton-bin
    ];
  };
}
