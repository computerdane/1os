{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.mc-backup;
in
{
  options.oneos.mc-backup = {
    enable = lib.mkEnableOption "Minecraft server backups via borgbackup";

    serverName = lib.mkOption {
      type = lib.types.str;
      description = "Name of the minecraft server (as defined in services.minecraft-servers.servers).";
    };

    repository = lib.mkOption {
      type = lib.types.str;
      description = "Borg repository path (e.g. ssh://user@host:port/./backups/minecraft).";
    };

    sshKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the SSH private key for accessing the storage box.";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "*-*-* 00/2:00:00";
      description = "Systemd OnCalendar interval for backups.";
    };

    prune = {
      keep = {
        hourly = lib.mkOption {
          type = lib.types.int;
          default = 12;
          description = "Number of hourly backups to keep.";
        };
        daily = lib.mkOption {
          type = lib.types.int;
          default = 7;
          description = "Number of daily backups to keep.";
        };
        weekly = lib.mkOption {
          type = lib.types.int;
          default = 4;
          description = "Number of weekly backups to keep.";
        };
        monthly = lib.mkOption {
          type = lib.types.int;
          default = 6;
          description = "Number of monthly backups to keep.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.borgbackup.jobs."mc-${cfg.serverName}" = {
      paths = [
        "${config.services.minecraft-servers.dataDir}/${cfg.serverName}/world"
      ];
      repo = cfg.repository;
      encryption.mode = "none";
      environment.BORG_RSH = "ssh -i ${cfg.sshKeyFile} -o StrictHostKeyChecking=accept-new";
      compression = "none";
      startAt = cfg.interval;
      user = config.services.minecraft-servers.user;
      group = config.services.minecraft-servers.group;

      prune.keep = {
        within = "1d";
        hourly = cfg.prune.keep.hourly;
        daily = cfg.prune.keep.daily;
        weekly = cfg.prune.keep.weekly;
        monthly = cfg.prune.keep.monthly;
      };

      preHook = ''
        TMUX_SOCK="/run/minecraft/${cfg.serverName}.sock"
        if ${pkgs.tmux}/bin/tmux -S "$TMUX_SOCK" list-sessions &>/dev/null; then
          ${pkgs.tmux}/bin/tmux -S "$TMUX_SOCK" send-keys C-u "save-all flush" Enter
          sleep 10
          ${pkgs.tmux}/bin/tmux -S "$TMUX_SOCK" send-keys C-u "save-off" Enter
          sleep 2
        fi
      '';

      postHook = ''
        TMUX_SOCK="/run/minecraft/${cfg.serverName}.sock"
        if ${pkgs.tmux}/bin/tmux -S "$TMUX_SOCK" list-sessions &>/dev/null; then
          ${pkgs.tmux}/bin/tmux -S "$TMUX_SOCK" send-keys C-u "save-on" Enter
        fi
      '';
    };
  };
}
