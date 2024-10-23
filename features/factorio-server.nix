{ config, pkgs, ... }:

let
  version = "2.0.9";
  factorio-headless-latest = pkgs.factorio-headless.override {
    versionsJson = pkgs.writeText "versions.json" (
      builtins.toJSON {
        x86_64-linux.headless.stable = {
          name = "factorio_headless_x64-${version}.tar.xz";
          needsAuth = false;
          sha256 = "sha256-9JkHez4sExNFLDUPH68X2zHK4qD6c49pFm6Xw8qjyG0=";
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

  cfg = config.services.factorio;
in
{
  services.factorio = {
    enable = true;
    package = factorio-headless-latest;
    openFirewall = true;
    game-password = "sex";
    lan = true;
  };

  systemd.services.factorio.postStart = ''
    cat ${mod-list-json} > /var/lib/${cfg.stateDirName}/mods/mod-list.json
  '';
}
