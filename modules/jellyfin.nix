{ config, lib, ... }:

let
  cfg = config.oneos.jellyfin;
in
{
  options.oneos.jellyfin =
    with lib;
    with types;
    {
      enable = mkEnableOption "jellyfin";
      subdomain = mkOption {
        type = str;
        default = "jellyfin";
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

      services.jellyfin = {
        enable = true;
        openFirewall = true;
      };

      services.nginx = {
        virtualHosts.${domain} = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8096";
            proxyWebsockets = true;
          };
        };
      };

    };
}
