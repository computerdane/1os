{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.gpu-nvidia;

  btop-cuda = pkgs.btop.override { cudaSupport = true; };
in
{
  options.oneos.gpu-nvidia.enable = lib.mkEnableOption "gpu-nvidia";

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable = true;

    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.open = true;

    environment.systemPackages = [ btop-cuda ];
    programs.fish.shellAliases.btop = "${btop-cuda}/bin/btop";
  };
}
