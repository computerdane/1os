{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.gpu-amd;
in
{
  options.oneos.gpu-amd.enable = lib.mkEnableOption "gpu-amd";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.btop-rocm ];
    programs.fish.shellAliases.btop = "${pkgs.btop-rocm}/bin/btop";
  };
}
