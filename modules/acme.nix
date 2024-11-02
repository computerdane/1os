{ config, lib, ... }:

let
  cfg = config.oneos.acme;
in
{
  options.oneos.acme =
    with lib;
    with types;
    {
      enable = mkEnableOption "acme";
      root = mkOption {
        type = bool;
        default = false;
      };
      subdomains = mkOption {
        type = listOf str;
        default = [ ];
      };
      email = mkOption {
        type = str;
        default = "admin@${config.oneos.domains.default}";
      };
    };

  config = lib.mkIf cfg.enable {
    sops.secrets.cloudflare-api-key = { };

    services.nginx.enable = true;

    security.acme = {
      acceptTerms = true;

      defaults = {
        email = cfg.email;
        group = config.services.nginx.group;
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        environmentFile = config.sops.secrets.cloudflare-api-key.path;
      };

      # Uncomment to use Let's Encrypt Staging Environment
      # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };
  };
}
