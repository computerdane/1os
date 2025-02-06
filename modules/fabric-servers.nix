{
  config,
  lib,
  pkgs,
  ...
}:

let
  servers = config.oneos.fabric-servers;
in
{
  options.oneos.fabric-servers =
    with lib;
    with types;
    mkOption {
      type = attrsOf (
        submodule (
          { name, ... }:
          {
            options = {
              enable = mkEnableOption "fabric-server";

              serviceName = mkOption {
                type = str;
                default = "fabric-server-${name}";
              };
              dataDir = mkOption {
                type = str;
                default = "/var/lib/fabric-server-${name}";
              };

              user = mkOption {
                type = str;
                default = "fabric-server-${name}";
              };
              group = mkOption {
                type = str;
                default = "fabric-server-${name}";
              };

              javaPackage = mkOption {
                type = package;
                default = pkgs.temurin-jre-bin-21;
              };
              mcVersion = mkOption {
                type = str;
                default = "latest";
              };

              port = mkOption {
                type = port;
                default = 25565;
              };
              rconPort = mkOption {
                type = port;
                default = 25566;
              };

              ops = mkOption {
                type = listOf str;
                default = [ ];
              };
              serverProperties = mkOption {
                type = attrsOf str;
                default = { };
              };
            };
          }
        )
      );
    };

  config.users.users =
    with lib.attrsets;
    mapAttrs' (
      name: cfg:
      nameValuePair cfg.user {
        isNormalUser = true;
        group = cfg.group;
      }
    ) servers;

  config.users.groups = with lib.attrsets; mapAttrs' (name: cfg: nameValuePair cfg.group { }) servers;

  config.systemd.services =
    (lib.attrsets.mapAttrs' (
      name: cfg:
      lib.attrsets.nameValuePair "${cfg.serviceName}-init" (
        lib.mkIf cfg.enable {
          script = ''
            mkdir -p "${cfg.dataDir}"
            chown "${cfg.user}:${cfg.group}" "${cfg.dataDir}"
          '';
          serviceConfig.Type = "oneshot";
        }
      )
    ) servers)
    // (lib.attrsets.mapAttrs' (
      name: cfg:
      lib.attrsets.nameValuePair cfg.serviceName (
        lib.mkIf cfg.enable {
          requires = [ "${cfg.serviceName}-init.service" ];
          after = [ "${cfg.serviceName}-init.service" ];
          wantedBy = [ "multi-user.target" ];
          path = [
            pkgs.fabric-installer
            pkgs.mcrcon
            pkgs.openssl
            cfg.javaPackage
          ];
          preStart = ''
            fabric-installer server -downloadMinecraft ${
              if cfg.mcVersion != "latest" then "-mcversion ${cfg.mcVersion}" else ""
            }
            echo "eula=true" > eula.txt

            echo "" > server.properties
            ${lib.concatStringsSep "\n" (
              lib.attrsets.mapAttrsToList (
                name: value:
                if name != "port" && name != "enable-rcon" && name != "rcon.port" && name != "rcon.password" then
                  ''echo "${name}=${value}" >> server.properties''
                else
                  ""
              ) cfg.serverProperties
            )}

            echo "enable-rcon=true" >> server.properties
            echo "port=${toString cfg.port}" >> server.properties
            echo "rcon.port=${toString cfg.rconPort}" >> server.properties

            openssl rand -base64 24 > .rcon-password
            chmod 600 .rcon-password
            echo "enable-rcon=true"
            echo "rcon.password=$(cat .rcon-password)" >> server.properties

            chmod 600 server.properties
          '';
          script = ''
            java -jar fabric-server-launch.jar
          '';
          postStart = ''
            for i in {1..10};
            do
              if mcrcon -P ${toString cfg.rconPort} -p $(cat .rcon-password) ${
                lib.concatStringsSep " " (lib.map (op: ''"op ${op}"'') cfg.ops)
              }; then
                break
              fi
              sleep 15
            done
          '';
          serviceConfig = {
            WorkingDirectory = cfg.dataDir;
            User = cfg.user;
            Group = cfg.group;
          };
        }
      )
    ) servers);
}
