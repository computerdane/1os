{
  hostname,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs) stdenv;
in
{

  oneos.development.enable = true;

  home.packages = lib.mkIf stdenv.isLinux (
    with pkgs;
    [
      prismlauncher
      signal-desktop
      temurin-jre-bin
      vesktop
      vintagestory
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

  services.easyeffects = lib.mkIf (hostname == "fishtank") {
    enable = true;
    extraPresets.nix-mic = builtins.fromJSON (builtins.readFile ./easyeffects-mic.json);
    preset = "nix-mic";
  };

}
