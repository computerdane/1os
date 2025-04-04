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
      python3
      rustc
    ];

    programs.bun.enable = true;
    programs.go.enable = true;

    programs.computerdane-helix.languages = {
      go.enable = true;
      web.enable = true;
      python.enable = true;
      rust.enable = true;
    };

    home.file.".cargo/config.toml".text = ''
      [target.x86_64-unknown-linux-gnu]
      linker = "${pkgs.clang}/bin/clang"
      rustflags = ["-C", "link-arg=-fuse-ld=${pkgs.mold}/bin/mold"]
    '';

  };
}
