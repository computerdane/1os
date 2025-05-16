{ lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  oneos = {
    desktop.enable = true;
    gaming.enable = true;
    gpu-amd.enable = true;
  };

  specialisation.nvidia.configuration = {
    oneos.gpu-amd.enable = lib.mkForce false;
    oneos.gpu-nvidia.enable = true;
  };
}
