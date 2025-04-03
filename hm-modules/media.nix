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
      aria2
      bop
      ffmpeg-full
    ];
    programs.mpv.enable = true;
    programs.yt-dlp.enable = true;
  };
}
