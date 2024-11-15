{
  config,
  lib,
  pkgs,
  pkgs-nf6,
  ...
}:

let
  cfg = config.oneos.nf6-db;
in
{
  options.oneos.nf6-db.enable = lib.mkEnableOption "nf6-db";

  config = lib.mkIf cfg.enable {
    sops.secrets.postgres-nf6_api-password-db = {
      owner = "postgres";
      group = "postgres";
    };
    sops.secrets.postgres-nf6_git-password-db = {
      owner = "postgres";
      group = "postgres";
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "nf6" ];
    };

    systemd.services.nf6-db-init = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.postgresql ];
      preStart = ''
        sleep 5
      '';
      script = ''
        PG_NF6_API_PASS=$(cat "${config.sops.secrets.postgres-nf6_api-password-db.path}")
        PG_NF6_GIT_PASS=$(cat "${config.sops.secrets.postgres-nf6_git-password-db.path}")

        cat "${pkgs-nf6.init-tables-sql}" >> /tmp/init.sql
        cat "${pkgs-nf6.init-api-user-sql}" >> /tmp/init.sql
        cat "${pkgs-nf6.init-git-user-sql}" >> /tmp/init.sql

        sed -i -e "s/PG_NF6_API_PASS/$PG_NF6_API_PASS/g" /tmp/init.sql
        sed -i -e "s/PG_NF6_GIT_PASS/$PG_NF6_GIT_PASS/g" /tmp/init.sql

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
