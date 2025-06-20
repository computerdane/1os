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
        home.packages = with pkgs; [
          hll-arty-calc
          hll-arty-tui
          mc-quick
        ];
      }

      (mkIf stdenv.isLinux {
        home.packages = with pkgs; [
          prismlauncher
          temurin-jre-bin
          vintagestory
        ];
        programs.obs-studio.enable = true;
      })

    ]);
}
