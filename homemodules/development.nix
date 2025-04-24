{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.development;
in
{
  options.oneos.development.enable = lib.mkEnableOption "development";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      cargo
      nodejs_22
      rustc
    ];

    programs.bun.enable = true;
    programs.gh.enable = true;
    programs.go.enable = true;

    programs.computerdane-helix.languages = {
      go.enable = true;
      web.enable = true;
      rust.enable = true;
      c.enable = true;
    };

  };
}
