{
  config,
  lib,
  pkgs,
  ...
}:

let
  mc-quick = config.services.mc-quick;
in
{
  options = {

    services.mc-quick = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {

            enable = lib.mkEnableOption "a minecraft server powered by mc-quick";

            autoStart = lib.mkOption {
              default = false;
              type = lib.types.bool;
              description = ''
                Whether or not to start the Minecraft server on boot.
              '';
            };

            mcVersion = lib.mkOption {
              default = "1.21.4";
              type = lib.types.str;
              description = ''
                Minecraft version.
              '';
            };

            loader = lib.mkOption {
              default = "vanilla";
              type = lib.types.strMatching "fabric|forge|vanilla";
              description = ''
                Which mod loader to use (`vanilla` if no mod loader desired).
              '';
            };

            forgeVersion = lib.mkOption {
              default = "recommended";
              type = lib.types.str;
              description = ''
                Which version of Minecraft Forge to download.
              '';
            };

            overwrite = lib.mkOption {
              default = false;
              type = lib.types.bool;
              description = ''
                Whether or not to re-download all mods and mod loaders,
                ignoring checksums that match.
              '';
            };

            javaPackage = lib.mkOption {
              default = pkgs.temurin-jre-bin;
              type = lib.types.package;
              description = ''
                The Java package to use. Make sure you use the right Java
                version for the version of Minecraft you are running.
              '';
            };

            acceptEula = lib.mkOption {
              default = false;
              type = lib.types.bool;
              description = ''
                Whether or not to accept Minecraft's EULA.
              '';
            };

            port = lib.mkOption {
              default = 25565;
              type = lib.types.port;
              description = ''
                The port for the Minecraft server. Will override all port
                options specified in server.properties. Used to configure
                the server and your firewall.
              '';
            };

            rconPort = lib.mkOption {
              default = 25575;
              type = lib.types.port;
              description = ''
                The RCON port for the Minecraft server. Will override all
                RCON port options specified in server.properties. Used to
                configure the server and your firewall.
              '';
            };

            rconPasswordFile = lib.mkOption {
              default = ".rcon-password";
              type = lib.types.str;
              description = ''
                Path to a file containing the server's RCON password. Will
                override all RCON password options specified in
                server.properties.
              '';
            };

            randomizeRconPassword = lib.mkOption {
              default = true;
              type = lib.types.bool;
              description = ''
                Whether or not to randomize the RCON password every time the
                server is started.
              '';
            };

            openFirewall = lib.mkOption {
              default = false;
              type = lib.types.bool;
              description = ''
                Opens the firewall for TCP/UDP traffic on the port specified
                by {option}`services.mc-quick.<name>.port`.
              '';
            };

            openFirewallRcon = lib.mkOption {
              default = false;
              type = lib.types.bool;
              description = ''
                Opens the firewall for TCP/UDP traffic on the port specified
                by {option}`services.mc-quick.<name>.rconPort`.
              '';
            };

            openFirewallExtraPorts = lib.mkOption {
              default = [ ];
              type = lib.types.listOf lib.types.port;
              description = ''
                Opens the firewall for TCP/UDP traffic on these extra ports.
              '';
            };

            ops = lib.mkOption {
              default = [ ];
              type = lib.types.listOf (
                lib.types.submodule {
                  options = {

                    uuid = lib.mkOption {
                      type = lib.types.str;
                      description = ''
                        The operator's
                        [UUID](https://minecraft.wiki/w/UUID).
                      '';
                    };

                    name = lib.mkOption {
                      type = lib.types.str;
                      description = ''
                        The operator's
                        [username](https://minecraft.wiki/w/Player#Username).
                      '';
                    };

                    level = lib.mkOption {
                      type = lib.types.int;
                      description = ''
                        The operator's
                        [permission level](https://minecraft.wiki/w/Permission_level).
                      '';
                    };

                    bypassesPlayerLimit = lib.mkOption {
                      type = lib.types.bool;
                      description = ''
                        If true, the operator can join the server even if
                        the player limit has been reached.
                      '';
                    };

                  };
                }
              );
              description = ''
                Directly maps to the server's
                [ops.json](https://minecraft.wiki/w/Ops.json)
              '';
            };

            whitelist = lib.mkOption {
              default = [ ];
              type = lib.types.listOf (
                lib.types.submodule {
                  options = {

                    uuid = lib.mkOption {
                      type = lib.types.str;
                      description = ''
                        The player's
                        [UUID](https://minecraft.wiki/w/UUID).
                      '';
                    };

                    name = lib.mkOption {
                      type = lib.types.str;
                      description = ''
                        The player's
                        [username](https://minecraft.wiki/w/Player#Username).
                      '';
                    };

                  };
                }
              );
              description = ''
                Directly maps to the server's
                [whitelist.json](https://minecraft.wiki/w/Whitelist.json)
              '';
            };

            enableWhitelist = lib.mkEnableOption "whitelisting";

            serverProperties = lib.mkOption {
              default = {
                motd = "Powered by NixOS!";
              };
              type = lib.types.attrsOf lib.types.str;
              description = ''
                Directly maps to the server's
                [server.properties](https://minecraft.fandom.com/wiki/Server.properties)
              '';
            };

            modrinthMods = lib.mkOption {
              default = [ ];
              type = lib.types.listOf lib.types.str;
              description = ''
                A list of Modrinth project ids/slugs to install.
              '';
            };

            modrinthModpack = lib.mkOption {
              default = "";
              type = lib.types.str;
              description = ''
                A Modrinth project id/slug to install as a modpack.
              '';
            };

            files = lib.mkOption {
              default = [ ];
              type = lib.types.listOf (
                lib.types.submodule {
                  options = {

                    path = lib.mkOption {
                      type = lib.types.str;
                      description = ''
                        The path of the file to write.
                      '';
                    };

                    text = lib.mkOption {
                      type = lib.types.lines;
                      description = ''
                        The contents of the file to write.
                      '';
                    };

                  };
                }
              );
              description = ''
                A list of files to write in the server's data directory.
                Useful for setting mod config options.
              '';
            };

          };
        }
      );
    };

  };

  config = {

    networking.firewall = lib.mkMerge (
      lib.attrsets.mapAttrsToList (
        name: cfg:
        lib.mkIf (cfg.enable) (
          let
            ports =
              (if cfg.openFirewall then [ cfg.port ] else [ ])
              ++ (if cfg.openFirewallRcon then [ cfg.rconPort ] else [ ])
              ++ cfg.openFirewallExtraPorts;
          in
          {
            allowedTCPPorts = ports;
            allowedUDPPorts = ports;
          }
        )
      ) mc-quick
    );

    systemd.services = lib.mkMerge (
      lib.attrsets.mapAttrsToList (
        name: cfg:
        let

          opsFile = pkgs.writeText "ops.json" (builtins.toJSON cfg.ops);
          whitelistFile = pkgs.writeText "whitelist.json" (builtins.toJSON cfg.whitelist);
          eulaFile = pkgs.writeText "eula.txt" "eula=${lib.trivial.boolToString cfg.acceptEula}";

          portStr = toString cfg.port;
          rconPortStr = toString cfg.rconPort;

          serverProperties = cfg.serverProperties // {
            server-port = portStr;
            "query.port" = portStr;
            enable-rcon = "true";
            "rcon.port" = rconPortStr;
            "rcon.password" = "RCON_PASSWORD";
            white-list = lib.trivial.boolToString cfg.enableWhitelist;
          };
          serverPropertiesFile = pkgs.writeText "server.properties" (
            lib.strings.concatStringsSep "\n" (
              lib.attrsets.mapAttrsToList (name: value: "${name}=${value}") serverProperties
            )
          );

        in
        {
          "mc-quick-${name}" = {
            wantedBy = lib.mkIf cfg.autoStart [ "multi-user.target" ];

            serviceConfig = {
              DynamicUser = true;
              StateDirectory = "mc-quick-${name}";
            };

            path =
              [
                cfg.javaPackage
                (pkgs.mc-quick.override { javaPackage = cfg.javaPackage; })
              ]
              ++ (with pkgs; [
                bash
                mcrcon
                openssl
              ]);

            environment.CONFIG_FILE = pkgs.writeText "config.json" (
              builtins.toJSON (
                with cfg;
                {
                  inherit loader overwrite;
                  mc-version = mcVersion;
                  forge-version = forgeVersion;
                  modrinth-modpack = modrinthModpack;
                  modrinth-mod = modrinthMods;
                }
              )
            );

            preStart = ''
              cd "$STATE_DIRECTORY"
              ln -sf "${opsFile}" ops.json
              ln -sf "${whitelistFile}" whitelist.json
              ln -sf "${eulaFile}" eula.txt
              ${
                if cfg.randomizeRconPassword then
                  ''
                    openssl rand -base64 32 > "${cfg.rconPasswordFile}"
                  ''
                else
                  ""
              }
              cat "${serverPropertiesFile}" > server.properties
              sed -i "/rcon.password=RCON_PASSWORD/d" server.properties
              echo -e "\n" >> server.properties
              echo "rcon.password=$(cat "${cfg.rconPasswordFile}")" >> server.properties
            '';

            script = ''
              cd "$STATE_DIRECTORY"
              mc-quick install
              ${lib.concatMapStringsSep "\n" (file: ''
                mkdir -p $(dirname "${file.path}")
                cat "${pkgs.writeText file.path file.text}" > "${file.path}"
              '') cfg.files}
              mc-quick start
            '';

            preStop = ''
              cd "$STATE_DIRECTORY"
              mcrcon -P ${rconPortStr} -p $(cat ${cfg.rconPasswordFile}) stop
            '';
          };
        }
      ) mc-quick
    );

  };
}
