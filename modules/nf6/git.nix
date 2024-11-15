{
  config,
  lib,
  pkgs,
  pkgs-nf6,
  ...
}:

let
  cfg = config.oneos.nf6-git;
in
{
  options.oneos.nf6-git =
    with lib;
    with types;
    {
      enable = mkEnableOption "nf6-git";
      user = mkOption {
        type = str;
        default = "git";
      };
      group = mkOption {
        type = str;
        default = "git";
      };
      port = mkOption {
        type = port;
        default = 6970;
      };
    };

  config =
    with cfg;
    lib.mkIf enable {
      sops.secrets.postgres-nf6_git-password-git = {
        owner = user;
        inherit group;
      };

      users.users.${user} = {
        isNormalUser = true;
        inherit group;
        packages = [ pkgs.git ];
      };
      users.groups.${group} = { };

      systemd.services.nf6-git-auth = {
        requires = [
          "postgresql.service"
          "nf6-db-init.service"
        ];
        after = [ "nf6-db-init.service" ];
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs-nf6.server-git-auth ];
        script = ''
          PG_PASS=$(cat "${config.sops.secrets.postgres-nf6_git-password-git.path}")
          nf6-git-auth listen \
            --dbUrl "postgres://nf6_git:$PG_PASS@localhost/nf6" \
            --gitShell "${pkgs-nf6.server-git-shell}/bin/nf6-git-shell"
        '';
        serviceConfig = {
          User = user;
          Group = group;
        };
      };

      systemd.tmpfiles.settings."10-nf6-git-repos"."/var/lib/nf6-git/repos".d = {
        inherit user group;
        mode = "0755";
      };

      systemd.tmpfiles.settings."10-nf6-git-auth"."/var/lib/nf6-git-auth/data".d = {
        inherit user group;
        mode = "0755";
      };

      services.openssh = {
        authorizedKeysCommand = ''/bin/authkeyscmd ask %u "%t %k"'';
        authorizedKeysCommandUser = "nobody";
      };

      systemd.services.copy-authkeyscmd = {
        wantedBy = [ "multi-user.target" ];
        script = ''
          cp "${pkgs-nf6.server-git-auth}/bin/nf6-git-auth" /bin/authkeyscmd
        '';
      };
    };
}
