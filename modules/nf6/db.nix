{
  config,
  lib,
  pkgs,
  pkgs-nf6,
  ...
}:

let
  cfg = config.oneos.nf6-db;

  initUserSql = pkgs.writeText "create-user.sql" ''
    create database nf6 owner nf6_api;
    grant usage, create on schema public to nf6_api;
    \c nf6;
    set role nf6_api;
  '';
in
{
  options.oneos.nf6-db.enable = lib.mkEnableOption "nf6-db";

  config = lib.mkIf cfg.enable {
    sops.secrets.postgres-nf6_api-password-db = {
      owner = "postgres";
      group = "postgres";
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "nf6" ];
    };

    systemd.services.nf6-db-init = {
      requires = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.postgresql ];
      preStart = ''
        sleep 5
      '';
      script = ''
        PG_PASS=$(cat "${config.sops.secrets.postgres-nf6_api-password-db.path}")
        echo "create user nf6_api with password '$PG_PASS';" > /tmp/init.sql
        cat "${initUserSql}" >> /tmp/init.sql
        cat "${pkgs-nf6.init-sql}" >> /tmp/init.sql

        psql -d nf6 -f /tmp/init.sql
      '';
      postStart = ''
        sleep 5
      '';
      serviceConfig = {
        User = "postgres";
        Group = "postgres";
        PrivateTmp = true;
      };
    };
  };
}
