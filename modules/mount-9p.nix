{ config, lib, ... }:

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

    fileSystems = lib.mkIf (!cfg.isHost) {
      ${cfg.path} = {
        device = cfg.host;
        fsType = "9p";
        options = [
          "aname=${cfg.path}"
          "version=9p2000.L"
          "uname=root"
          "access=any"
        ];
      };
    };

  };
}
