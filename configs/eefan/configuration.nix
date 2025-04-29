{ lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  oneos = {
    desktop.enable = true;
    gaming.enable = true;
    gpu-amd.enable = true;
    nixbuild.enable = true;
  };

  specialisation.nvidia.configuration = {
    oneos.gpu-amd.enable = lib.mkForce false;
    oneos.gpu-nvidia.enable = true;
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
  };
}
