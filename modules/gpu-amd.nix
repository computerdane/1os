{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  cfg = config.oneos.gpu-amd;
in
{
  options.oneos.gpu-amd.enable = lib.mkEnableOption "gpu-amd";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs-unstable.btop-rocm ];
    programs.fish.shellAliases.btop = "${pkgs-unstable.btop-rocm}/bin/btop";
  };
}
