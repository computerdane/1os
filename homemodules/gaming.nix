{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs) stdenv;
  cfg = config.oneos.gaming;
in
{
  options.oneos.gaming.enable = lib.mkEnableOption "gaming";

  config =
    with lib;
    mkIf cfg.enable (mkMerge [

      {
        home.packages = with pkgs.dane; [
          hll-arty-calc
          hll-arty-tui
          mc-quick
        ];
      }

      (mkIf stdenv.isLinux {
        home.packages = [ pkgs.prismlauncher ];
        programs.obs-studio.enable = true;
      })

    ]);
}
