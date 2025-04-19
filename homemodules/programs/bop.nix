{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.bop;
in
{
  options.programs.bop =
    with lib;
    with types;
    {
      enable = mkEnableOption "bop";
      settings = mkOption {
        type = attrs;
        default = { };
        description = "Maps to bop JSON config";
      };
    };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.dane.bop ];
    xdg.configFile."bop/config.json".text = builtins.toJSON cfg.settings;
  };
}
