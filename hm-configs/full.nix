{ pkgs, lib, ... }:

let
  inherit (pkgs) stdenv;
in
lib.mkMerge [
  {
    programs.computerdane-helix.languages = {
      go.enable = true;
      web.enable = true;
      python.enable = true;
    };
    programs.mpv.enable = true;
  }
  (lib.mkIf stdenv.isLinux {
    home.packages = with pkgs; [
      mumble
      prismlauncher
      signal-desktop
      vesktop
    ];

    programs.firefox.enable = true;
    programs.obs-studio.enable = true;
  })
]
