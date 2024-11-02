{
  config,
  lib,
  pkgs,
  ...
}:

let
  version = "2.0.13";
  factorio-headless-latest = pkgs.factorio-headless.override {
    versionsJson = pkgs.writeText "versions.json" (
      builtins.toJSON {
        x86_64-linux.headless.stable = {
          name = "factorio_headless_x64-${version}.tar.xz";
          needsAuth = false;
          sha256 = "sha256-J7NpAaOeWTrfKEGMAoYULGx6n4PRVpY8c2m9QFolx9E=";
          tarDirectory = "x64";
          url = "https://www.factorio.com/get-download/${version}/headless/linux64";
          inherit version;
        };
      }
    );
  };

  mod-list-json = pkgs.writeText "mod-list.json" (
    builtins.toJSON {
      mods = [
        {
          name = "base";
          enabled = true;
        }
        {
          name = "elevated-rails";
          enabled = false;
        }
        {
          name = "quality";
          enabled = false;
        }
        {
          name = "space-age";
          enabled = false;
        }
      ];
    }
  );

  cfg = config.oneos.factorio-server;
in
{
  options.oneos.factorio-server.enable = lib.mkEnableOption "factorio-server";

  config = lib.mkIf cfg.enable {
    sops.secrets.factorio-settings = { };

    services.factorio = {
      enable = true;
      package = factorio-headless-latest;
      openFirewall = true;
      game-name = "nf6.sh";
      lan = true;
      admins = [
        "computerdane"
        "ethan22"
      ];
      extraSettingsFile = config.sops.secrets.factorio-settings.path;
    };

    # Service tends to fail when system is booting up, this gives it time to try again once network is online
    systemd.services.factorio.serviceConfig.RestartSec = 10;

    systemd.services.factorio.postStart = ''
      cat ${mod-list-json} > /var/lib/${config.services.factorio.stateDirName}/mods/mod-list.json
    '';
  };
}
