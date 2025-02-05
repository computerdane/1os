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
            cfg.javaPackage
          ];
          preStart = ''
            fabric-installer server -downloadMinecraft ${
              if cfg.mcVersion != "latest" then "-mcversion ${cfg.mcVersion}" else ""
            }
            echo "eula=true" > eula.txt
            ${lib.concatStringsSep "\n" (
              lib.attrsets.mapAttrsToList (
                name: value: ''echo "${name}=${value}" > server.properties''
              ) cfg.serverProperties
            )}
          '';
          script = ''
            java -jar fabric-server-launch.jar
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
