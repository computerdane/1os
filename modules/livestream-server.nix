{ config, lib, ... }:

let
  cfg = config.oneos.livestream-server;
in
{
  options.oneos.livestream-server =
    with lib;
    with types;
    {
      enable = mkEnableOption "livestream-server";
      subdomain = mkOption {
        type = str;
        default = "live";
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
      sops.secrets.owncast-basic-auth = with config.users.users.nginx; {
        owner = name;
        inherit group;
      };

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

      services.owncast = {
        enable = true;
        port = 8333;
        listen = "0.0.0.0";
      };

      services.nginx =
        let
          proxyPass = "http://[::1]:${toString config.services.owncast.port}";
        in
        {
          virtualHosts.${domain} = {
            enableACME = true;
            forceSSL = true;
            locations."/" = {
              inherit proxyPass;
              proxyWebsockets = true;
              basicAuthFile = config.sops.secrets.owncast-basic-auth.path;
            };
            locations."/admin".proxyPass = "${proxyPass}/admin";
          };
        };
    };
}
