{ lib, pkgs, ... }:

let
  inherit (pkgs) stdenv;
in
{

  oneos.development.enable = true;

  home.packages = lib.mkIf stdenv.isLinux (
    with pkgs;
    [
      javaPackages.compiler.temurin-bin.jre-25
      mumble
      prismlauncher
      signal-desktop
      vesktop
    ]
  );

  programs = {

    firefox.enable = true;
    obs-studio.enable = true;

    plasma = {
      enable = true;
      workspace.wallpaperSlideShow.path = "${
        pkgs.fetchFromGitHub {
          owner = "computerdane";
          repo = "wallpapers";
          rev = "main";
          hash = "sha256-6WFLG71QcmPQe7b/wqbeX65wbJ7LxZBJZhx8m4cqqZ0=";
        }
      }/artemis2";
      powerdevil.AC = {
        autoSuspend.action = "nothing";
        powerButtonAction = "shutDown";
        powerProfile = "performance";
      };
      kscreenlocker.autoLock = false;
    };

  };

}
