{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.mount-9p;
in
{
  options.oneos.mount-9p =
    with lib;
    with types;
    {
      enable = mkEnableOption "mount-9p";
      path = mkOption {
        type = str;
        default = "/nas";
      };
      isHost = mkOption {
        type = bool;
        default = false;
      };
      host = mkOption {
        type = str;
        default = "10.105.0.1";
      };
    };

  config = lib.mkIf cfg.enable {

    services.diod = lib.mkIf cfg.isHost {
      enable = true;
      exports = [ cfg.path ];
      userdb = true;
    };

    systemd.services."mount-nas" = lib.mkIf (!cfg.isHost) {
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      path = with pkgs; [
        mount
        umount
      ];
      script = ''
        mkdir -p "${cfg.path}"
        mount -t 9p -n "${cfg.host}" "${cfg.path}" "-oaname=${cfg.path},version=9p2000.L,uname=root,access=any,trans=tcp"
      '';
      preStop = ''
        umount -l "${cfg.path}"
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };

  };
}
