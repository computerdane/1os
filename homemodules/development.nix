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
  options.oneos.development = {
    enable = lib.mkEnableOption "development";
    fknPython = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {

    home.packages = lib.mkMerge [
      (with pkgs; [
        cargo
        nodejs_22
        rustc
        uv
      ])
      (lib.mkIf cfg.fknPython [ pkgs.python3 ])
    ];

    programs.bun.enable = true;
    programs.gh.enable = true;
    programs.go.enable = true;

    programs.computerdane-helix = {
      enable = true;
      defaultEditor = true;
      languages = {
        c.enable = true;
        go.enable = true;
        nix.enable = true;
        python.enable = true;
        rust.enable = true;
        web.enable = true;
      };
    };

  };
}
