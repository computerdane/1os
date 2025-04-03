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
      enable = mkEnableOption "shell_gpt";
      defaultModel = mkOption {
        type = str;
        default = "gpt-4o";
        description = "Default OpenAI model to use";
      };
    };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.shell-gpt ];
    home.editable-file.".config/shell_gpt/.sgptrc".text = ''
      DEFAULT_MODEL=${cfg.defaultModel}
    '';
  };
}
