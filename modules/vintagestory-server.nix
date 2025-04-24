{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.vintagestory-server;
in
{
  options.oneos.vintagestory-server =
    with lib;
    with types;
    {
      enable = mkEnableOption "vintagestory-server";
      package = mkPackageOption pkgs "vintagestory" { };
      port = mkOption {
        type = port;
        default = 42420;
      };
      openFirewall = mkEnableOption "open firewall";
    };

  config = lib.mkIf cfg.enable {

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    systemd.services.vintagestory-server = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        WorkingDirectory = "/tmp";
        ExecStart = ''${cfg.package}/bin/vintagestory-server --dataPath $STATE_DIRECTORY --port ${toString cfg.port}'';
      };
    };

  };
}
