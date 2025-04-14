{ config, lib, ... }:

let
  cfg = config.oneos.profiles.danes-desktop;
in
{
  options.oneos.profiles.danes-desktop.enable = lib.mkEnableOption "profile: danes-desktop";

  config = lib.mkIf cfg.enable {

    oneos = {
      profiles.full.enable = true;

      hll.enable = true;
      kde.enable = true;
      wallpapers.enable = true;
    };

  };
}
