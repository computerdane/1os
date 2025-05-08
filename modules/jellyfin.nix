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
      openFirewall = mkEnableOption "open firewall";
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

      oneos.dynamic-dns.subdomains = [ cfg.subdomain ];

      services.jellyfin = {
        enable = true;
        openFirewall = cfg.openFirewall;
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
