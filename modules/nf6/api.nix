{
  config,
  lib,
  pkgs-nf6,
  ...
}:

let
  cfg = config.oneos.nf6-api;
in
{
  options.oneos.nf6-api =
    with lib;
    with types;
    {
      enable = mkEnableOption "nf6-api";
      user = mkOption {
        type = str;
        default = "nf6-api";
      };
      group = mkOption {
        type = str;
        default = "nf6-api";
      };
      portInsecure = mkOption {
        type = port;
        default = 6968;
      };
      portSecure = mkOption {
        type = port;
        default = 6969;
      };
    };

  config =
    with cfg;
    lib.mkIf enable {
      sops.secrets.postgres-nf6_api-password-api = {
        owner = user;
        inherit group;
      };

      networking.firewall.allowedTCPPorts = [
        portInsecure
        portSecure
      ];
      networking.firewall.allowedUDPPorts = [
        portInsecure
        portSecure
      ];

      users.users.${user} = {
        isNormalUser = true;
        inherit group;
      };
      users.groups.${group} = { };

      systemd.services.nf6-api = {
        requires = [
          "postgresql.service"
          "nf6-db-init.service"
        ];
        after = [ "nf6-db-init.service" ];
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs-nf6.server-api ];
        script = ''
          PG_PASS=$(cat "${config.sops.secrets.postgres-nf6_api-password-api.path}")
          nfapi \
            --dbUrl "postgres://nf6_api:$PG_PASS@localhost/nf6" \
            --portInsecure "${toString portInsecure}" \
            --portSecure "${toString portSecure}"
        '';
        serviceConfig = {
          User = user;
          Group = group;
        };
      };

      systemd.tmpfiles.settings."10-nf6-api"."/var/lib/nfapi".d = {
        inherit user group;
        mode = "0755";
      };
    };
}
