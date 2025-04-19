{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.net-utils;
in
{
  options.oneos.net-utils.enable = lib.mkEnableOption "net-utils";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      aria2
      curl
      netcat
      nmap
      wget
    ];
  };
}
