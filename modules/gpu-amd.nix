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
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      # https://nixos.org/manual/nixos/stable/index.html#sec-gpu-accel-vulkan-amd
      # use amdvlk driver, vaapi, and opencl
      extraPackages = with pkgs; [
        amdvlk
        libva
        rocmPackages.clr.icd
      ];
      extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
    };

    environment.systemPackages = [ pkgs.btop-rocm ];
    programs.fish.shellAliases.btop = "${pkgs.btop-rocm}/bin/btop";
  };
}
