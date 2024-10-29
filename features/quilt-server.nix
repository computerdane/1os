{
  config,
  lib,
  pkgs-1os,
  ...
}:

let
  user = "quilt-server";
  group = "quilt-server";

  stateDir = "/var/lib/quilt-server/data";

  cfg = config.oneos.quilt-server;
in
{
  options.oneos.quilt-server.enable = lib.mkEnableOption "quilt-server";

  config = lib.mkIf cfg.enable {
    # environment.systemPackages = [ pkgs-1os.quilt-server ];

    networking.firewall.allowedTCPPorts = [ 25565 ];
    networking.firewall.allowedUDPPorts = [ 25565 ];

    users.users.${user} = {
      isNormalUser = true;
      inherit group;
    };
    users.groups.${group} = { };

    systemd.tmpfiles.settings."10-quilt-server".${stateDir}.d = {
      inherit user group;
      mode = "0755";
    };

    systemd.services.quilt-server = {
      path = with pkgs-1os; [ quilt-server ];
      serviceConfig = {
        WorkingDirectory = stateDir;
        User = user;
        Group = group;
      };
      script = ''
        quilt-server .
      '';
    };
  };
}
