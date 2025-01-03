{
  config,
  lib,
  ...
}:

let
  cfg = config.oneos.gpu-nvidia;
in
{
  options.oneos.gpu-nvidia.enable = lib.mkEnableOption "gpu-nvidia";

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable = true;

    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.open = true;
  };
}
