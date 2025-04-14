{ config, lib, ... }:

let
  cfg = config.oneos.wallpapers;
in
{
  options.oneos.wallpapers.enable = lib.mkEnableOption "epic wallpapers";

  config = lib.mkIf cfg.enable {
    programs.plasma = {
      enable = true;
      workspace.wallpaperSlideShow.path = ./.;
    };
  };
}
