{ config, pkgs, ... }:

let
  mcPort = 52225;
  mcVoicePort = 53335;
  mcMapPort = 54445;
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

        jvmOpts = "-Xms5G -Xmx5G";

        symlinks = {
          "mods" = "${modpack}/mods";
        };

        serverProperties = {
          allow-flight = true;
          difficulty = "hard";
          enforce-whitelist = true;
          gamemode = "survival";
          max-players = 20;
          motd = "welcome to danecraft";
          "query.port" = mcPort;
          region-file-compression = "lz4";
          server-port = mcPort;
          simulation-distance = 10;
          spawn-protection = 0;
          sync-chunk-writes = false;
          view-distance = 12;
          white-list = true;
        };

        files = {
          "config/voicechat/voicechat-server.properties".value = {
            port = mcVoicePort;
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
              port = mcMapPort;
            };
          };
        };
      };
  };
  oneos.mc-backup = {
    enable = true;
    serverName = "fabric";
    repository = "ssh://u575698@u575698.your-storagebox.de:23/./minecraft-backups";
    sshKeyFile = "/srv/minecraft/.ssh/id_ed25519";
  };
  users.users.dane.extraGroups = [ "minecraft-servers" ];
  networking.firewall.allowedTCPPorts = [
    mcPort
    mcMapPort
  ];
  networking.firewall.allowedUDPPorts = [
    mcPort
    mcVoicePort
  ];
}
