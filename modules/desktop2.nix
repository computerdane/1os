{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.desktop2;
in
{
  options.oneos.desktop2.enable = lib.mkEnableOption "desktop2";

  config = lib.mkIf cfg.enable {
    fonts.packages = with pkgs.nerd-fonts; [ comic-shanns-mono ];

    programs.hyprland.enable = true;

    services.printing.enable = true;

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "dane";

    # enable ozone wayland support in chromium and electron apps
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
