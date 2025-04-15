{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.shell-gpt;
in
{
  options.programs.shell-gpt =
    with lib;
    with types;
    {
      enable = mkEnableOption "shell-gpt";
      settings = mkOption {
        type = attrsOf str;
        default = { };
        description = "shell_gpt configuration file";
      };
    };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.shell-gpt ];
    home.editable-file.".config/shell_gpt/.sgptrc".text = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: "${name}=${value}") cfg.settings
    );
  };
}
