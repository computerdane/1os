{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.social;
in
{
  options.oneos.social.enable = lib.mkEnableOption "social";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      mumble
      signal-desktop
      vesktop
    ];
  };
}
