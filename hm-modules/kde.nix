{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs) stdenv;
  cfg = config.oneos.kde;
in
{
  options.oneos.kde.enable = lib.mkEnableOption "KDE settings";

  config = lib.mkIf cfg.enable {

    programs.firefox.enable = stdenv.isLinux;
    programs.plasma = {
      enable = true;
      powerdevil.AC = {
        autoSuspend.action = "nothing";
        powerButtonAction = "shutDown";
        powerProfile = "performance";
      };
      kscreenlocker.autoLock = false;
    };

  };
}
