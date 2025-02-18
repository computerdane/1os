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
                default = "1.21.4";
              };

              port = mkOption {
                type = port;
                default = 25565;
              };
              rconPort = mkOption {
                type = port;
                default = 25566;
              };

              openFirewall = mkEnableOption "open mc server port";
              openFirewallRcon = mkEnableOption "open mc rcon port";
              openExtraTcpPorts = mkOption {
                type = listOf port;
                default = [ ];
              };
              openExtraUdpPorts = mkOption {
                type = listOf port;
                default = [ ];
              };

              ops = mkOption {
                type = listOf str;
                default = [ ];
              };
              enableWhitelist = mkEnableOption "whitelist";
              whitelist = mkOption {
                type = listOf str;
                default = [ ];
              };
              serverProperties = mkOption {
                type = attrsOf str;
                default = { };
              };

              modrinthMods = mkOption {
                type = listOf str;
                default = [ ];
              };

              modConfigs = mkOption {
                type = listOf (submodule {
                  options = {
                    path = mkOption {
                      type = str;
                      default = name;
                    };
                    text = mkOption {
                      type = str;
                      default = "";
                    };
                  };
                });

                default = [ ];
              };
            };
          }
        )
      );

      default = { };
    };

  config.networking = lib.mkMerge (
    lib.attrsets.mapAttrsToList (
      name: cfg:
      let
        ports =
          (if cfg.openFirewall then [ cfg.port ] else [ ])
          ++ (if cfg.openFirewallRcon then [ cfg.rconPort ] else [ ]);
      in
      lib.mkIf (cfg.enable) {

        firewall.allowedTCPPorts = ports ++ cfg.openExtraTcpPorts;
        firewall.allowedUDPPorts = ports ++ cfg.openExtraUdpPorts;

      }
    ) servers
  );

  config.users = lib.mkMerge (
    lib.attrsets.mapAttrsToList (
      name: cfg:
      lib.mkIf (cfg.enable) {

        users.${cfg.user} = {
          isNormalUser = true;
          group = cfg.group;
        };

        groups.${cfg.group} = { };

      }
    ) servers
  );

  config.systemd = lib.mkMerge (
    lib.attrsets.mapAttrsToList (
      name: cfg:
      lib.mkIf (cfg.enable) {

        services."${cfg.serviceName}-init" = {
          script = ''
            mkdir -p "${cfg.dataDir}"
            chown "${cfg.user}:${cfg.group}" "${cfg.dataDir}"
          '';
          serviceConfig.Type = "oneshot";
        };

        services.${cfg.serviceName} = {
          requires = [ "${cfg.serviceName}-init.service" ];
          after = [ "${cfg.serviceName}-init.service" ];
          wantedBy = [ "multi-user.target" ];

          path =
            with pkgs;
            [
              curl
              fabric-installer
              jq
              mcrcon
              openssl
              wget
            ]
            ++ [ cfg.javaPackage ];

          preStart = ''
            # Download server jar
            fabric-installer server -downloadMinecraft -mcversion "${cfg.mcVersion}"

            # Accept EULA
            echo "eula=true" > eula.txt

            # Add attributes from cfg.serverProperties to server.properties
            ${lib.concatStringsSep "\n" (
              lib.attrsets.mapAttrsToList (
                name: value:
                if name != "port" && name != "enable-rcon" && name != "rcon.port" && name != "rcon.password" then
                  ''echo "${name}=${value}" >> server.properties''
                else
                  ""
              ) cfg.serverProperties
            )}

            # Generate a random password for RCON
            openssl rand -base64 24 > .rcon-password
            chmod 600 .rcon-password

            # Set server.properties options managed by this Nix module
            rm -f server.properties
            echo "port=${toString cfg.port}" >> server.properties
            echo "enable-rcon=true" >> server.properties
            echo "rcon.port=${toString cfg.rconPort}" >> server.properties
            echo "rcon.password=$(cat .rcon-password)" >> server.properties
            chmod 600 server.properties

            # Populate a list of mod URLs from Modrinth
            rm -f .mod-urls
            for mod in ${lib.concatStringsSep " " cfg.modrinthMods}; do
              url=$(curl "https://api.modrinth.com/v2/project/$mod/version?loaders=%5B%22fabric%22%5D&game_versions=%5B%22${cfg.mcVersion}%22%5D" | jq -r ".[0].files[0].url")
              if [[ "$url" == "null" ]]; then
                echo "Could not find mod: $mod"
                exit 1
              else
                echo "$url" >> .mod-urls
              fi
            done

            # Download mods
            rm -rf mods
            mkdir -p mods
            cd mods
            wget -i ../.mod-urls
            cd ..

            # Write mod configs
            rm -rf config
            mkdir -p config
            cd config
            ${lib.concatMapStringsSep "\n" (modConfig: ''
              mkdir -p "$(dirname "${modConfig.path}")"
              cat "${pkgs.writeText modConfig.path modConfig.text}" > "${modConfig.path}"
            '') cfg.modConfigs}
            cd ..

            # Clear ops and whitelist since postStart script configures them
            rm -f ops.json whitelist.json
          '';

          script = ''
            java -jar fabric-server-launch.jar
          '';

          postStart =
            let
              commands =
                [ "whitelist ${if cfg.enableWhitelist then "on" else "off"}" ] # Turn on whitelist
                ++ (map (user: "whitelist add ${user}") cfg.whitelist) # Whitelist users
                ++ (map (user: "op ${user}") cfg.ops); # Op users
            in
            ''
              # Try to run post-start RCON commands every 15 seconds
              for i in {1..10}; do
                if
                  mcrcon -P ${toString cfg.rconPort} -p $(cat .rcon-password) \
                    ${lib.concatMapStringsSep " " (cmd: ''"${cmd}"'') commands}
                then
                  break
                fi
                sleep 15
              done
            '';

          preStop = ''
            mcrcon -P ${toString cfg.rconPort} -p $(cat .rcon-password) stop
          '';

          serviceConfig = {
            WorkingDirectory = cfg.dataDir;
            User = cfg.user;
            Group = cfg.group;
          };
        };

      }
    ) servers
  );
}
