{ lib, pkgs, ... }:

let
  inherit (pkgs) stdenv;
in
{

  oneos.development.enable = true;

  home.packages = lib.mkIf stdenv.isLinux (
    with pkgs;
    [
      jellyfin-desktop
      mumble
      prismlauncher
      signal-desktop
      temurin-jre-bin
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
          hash = "sha256-LSnUOGbQoaVyct1QuE59J6vTsnYzm+WaH7xyi8gcXTw=";
        }
      }/rivals";
      powerdevil.AC = {
        autoSuspend.action = "nothing";
        powerButtonAction = "shutDown";
        powerProfile = "performance";
      };
      kscreenlocker.autoLock = false;
    };

  };

}
