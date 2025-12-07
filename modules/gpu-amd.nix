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
      # vaapi and opencl
      extraPackages = with pkgs; [
        libva
        rocmPackages.clr.icd
      ];
    };

    environment.systemPackages = with pkgs; [
      btop-rocm
      radeontop
    ];
    programs.fish.shellAliases.btop = "${pkgs.btop-rocm}/bin/btop";
  };
}
