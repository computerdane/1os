{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs) stdenv;
  cfg = config.oneos.social;
in
{
  options.oneos.social.enable = lib.mkEnableOption "social";

  config =
    with lib;
    mkIf cfg.enable (
      mkIf stdenv.isLinux {
        home.packages = with pkgs; [
          mumble
          signal-desktop
          vesktop
        ];
      }
    );
}
