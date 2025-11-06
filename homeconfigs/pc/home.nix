{ pkgs, ... }:

{

  oneos.development.enable = true;

  home.packages = with pkgs; [
    kdePackages.dolphin
    prismlauncher
    signal-desktop
    temurin-jre-bin
    vesktop
    vintagestory
    waybar
    wl-clipboard
    wofi
  ];

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

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

}
