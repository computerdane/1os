{ lib, pkgs, ... }:

let
  inherit (pkgs) stdenv;

  # From https://discourse.nixos.org/t/java-filechooser-glib-gio-error/69381/4
  # Fixes issue with Java file picker in Axiom mod
  prismlauncher-wrapped = pkgs.symlinkJoin {
    name = "prismlauncher-wrapped";
    paths = [ pkgs.prismlauncher ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram $out/bin/prismlauncher \
        --set XDG_DATA_DIRS "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    '';
  };
in
{

  oneos.development.enable = true;

  home.packages = lib.mkIf stdenv.isLinux (
    with pkgs;
    [
      javaPackages.compiler.temurin-bin.jre-25
      mumble
      prismlauncher-wrapped
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
