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
      ipv4 = mkOption {
        type = bool;
        default = true;
      };
    };

  config =
    let
      domain = "${cfg.subdomain}.${cfg.domain}";
    in
    lib.mkIf cfg.enable {

      oneos.dynamic-dns.subdomains = [ cfg.subdomain ];

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
