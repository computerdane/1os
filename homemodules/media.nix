{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.media;
in
{
  options.oneos.media.enable = lib.mkEnableOption "media";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      ffmpeg-full
      managarr
    ];

    programs.mpv.enable = true;
    programs.yt-dlp.enable = true;

    programs.bop = {
      enable = true;
      settings = {
        host = "nf6.sh";
        dir = "/nas";
      };
    };

  };
}
