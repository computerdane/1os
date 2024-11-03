{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.desktop;
in
{
  options.oneos.desktop.enable = lib.mkEnableOption "desktop";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.wl-clipboard ];

    fonts.packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "Meslo"
          "FiraCode"
        ];
      })
    ];

    services.xserver.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.desktopManager.plasma6.enable = true;

    services.printing.enable = true;

    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    users.users.dane.extraGroups = [ "networkmanager" ];

    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "dane";
    services.displayManager.defaultSession = "plasma";
  };
}