{
  config,
  pkgs,
  lib,
  ...
}:

let
  port = 25565;
  vcPort = 24454;
  mapPort = 8100;
in
{
  imports = [ ./hardware-configuration.nix ];

  systemd.network.networks."20-lan" = {
    name = "enp3s0";
    DHCP = "no";
    gateway = [
      "10.105.25.1"
      "2600:1700:280:496e::1"
    ];
    networkConfig.Address = [
      "10.105.25.2/24"
      "2600:1700:280:496e::2/64"
    ];
  };

  oneos = {
    desktop.enable = true;
    gaming.enable = true;
    gpu-nvidia.enable = true;
  };

  # Minecraft server settings.
  programs.tmux.enable = true;
  users.users.minecraft-servers = {
    isSystemUser = true;
    group = "minecraft-servers";
    home = config.services.minecraft-servers.dataDir;
    createHome = true;
  };
  users.groups.minecraft-servers = { };
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    user = "minecraft-servers";
    group = "minecraft-servers";
    servers.fabric =
      let
        modpack = pkgs.fetchPackwizModpack {
          src = ./fabric-mods;
          packHash = "sha256-ZACuiFDuxof2MiU3h3cgSBwIfBeSQOeippFOB0R34iM=";
        };
      in
      {
        enable = true;

        # Specify the custom minecraft server package.
        package = pkgs.fabricServers.fabric-26_1_2.override {
          # Specific fabric loader version.
          loaderVersion = "0.19.1";
          # Specific Java version.
          jre_headless = pkgs.jdk25_headless;
        };

        jvmOpts = "-Xms3G -Xmx3G";

        symlinks = {
          "mods" = "${modpack}/mods";
        };

        serverProperties = {
          allow-flight = true;
          difficulty = "hard";
          enforce-whitelist = true;
          gamemode = "survival";
          max-players = 10;
          motd = "welcome to danecraft";
          "query.port" = 52225;
          region-file-compression = "lz4";
          server-port = 52225;
          simulation-distance = 10;
          spawn-protection = 0;
          sync-chunk-writes = false;
          view-distance = 12;
          white-list = true;
        };

        files = {
          "config/voicechat/voicechat-server.properties".value = {
            port = 53335;
          };
          "config/bluemap/core.conf" = {
            format = pkgs.formats.hocon { };
            value = {
              accept-download = true;
            };
          };
          "config/bluemap/plugin.conf" = {
            format = pkgs.formats.hocon { };
            value = {
              live-player-markers = false;
            };
          };
          "config/bluemap/webserver.conf" = {
            format = pkgs.formats.hocon { };
            value = {
              port = 54445;
            };
          };
        };
      };
  };

  services.minecraft-server = {
    enable = true;
    eula = true;
    jvmOpts = "-Xms5G -Xmx5G";
    package = pkgs.javaPackages.compiler.temurin-bin.jre-25;
  };

  systemd.services.minecraft-server =
    let
      cfg = config.services.minecraft-server;
    in
    {
      serviceConfig = {
        ExecStart = lib.mkForce "${cfg.package}/bin/java ${cfg.jvmOpts} -jar server.jar nogui";
      };
    };

  users.users.minecraft.homeMode = "770";
  users.users.dane.extraGroups = [
    "minecraft"
    "minecraft-servers"
  ];

  networking.firewall =
    let
      ports = [
        port
        vcPort
        mapPort
      ];
    in
    {
      allowedUDPPorts = ports;
      allowedTCPPorts = ports;
    };
}
