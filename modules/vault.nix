{ config, lib, ... }:

let
  cfg = config.oneos.vault;
in
{
  options.oneos.vault =
    with lib;
    with types;
    {
      enable = mkEnableOption "vault";
      subdomain = mkOption {
        type = str;
        default = "vault";
      };
      domain = mkOption {
        type = str;
        default = config.oneos.domains.default;
      };
    };

  config =
    let
      domain = "${cfg.subdomain}.${cfg.domain}";
    in
    lib.mkIf cfg.enable {

      oneos = {
        acme.enable = true;
        dynamic-dns = {
          enable = true;
          ipv4 = true;
          subdomains = [ cfg.subdomain ];
          domains = [ cfg.domain ];
        };
        nginx.enable = true;
      };

      services.vaultwarden = {
        enable = true;
        config = {
          ROCKET_ADDRESS = "::1";
          ROCKET_PORT = 8222;
          DOMAIN = "https://${domain}";
          SIGNUPS_ALLOWED = false;
        };
      };

      services.nginx = {
        virtualHosts.${domain} = {
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://[::1]:${toString config.services.vaultwarden.config.ROCKET_PORT}";
        };
      };

    };
}
