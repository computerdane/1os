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
  options.oneos.gpu-amd = {
    enable = lib.mkEnableOption "gpu-amd";
    amdvlk = lib.mkEnableOption "amdvlk";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics = lib.mkMerge [
      {
        enable = true;
        enable32Bit = true;
        # vaapi and opencl
        extraPackages = with pkgs; [
          libva
          rocmPackages.clr.icd
        ];
      }
      (lib.mkIf cfg.amdvlk {
        # https://nixos.org/manual/nixos/stable/index.html#sec-gpu-accel-vulkan-amd
        # use amdvlk driver
        extraPackages = with pkgs; [ amdvlk ];
        extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
      })
    ];

    environment.systemPackages = with pkgs; [
      btop-rocm
      radeontop
    ];
    programs.fish.shellAliases.btop = "${pkgs.btop-rocm}/bin/btop";
  };
}
