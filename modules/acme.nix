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
      email = mkOption {
        type = str;
        default = "admin@${config.oneos.domains.default}";
      };
      useStaging = mkOption {
        description = "Whether or not to use the Let's Encrypt staging environment";
        type = bool;
        default = false;
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
        dnsPropagationCheck = true;
        environmentFile = config.sops.secrets.cloudflare-api-key.path;
        server = lib.mkIf cfg.useStaging "https://acme-staging-v02.api.letsencrypt.org/directory";
      };
    };
  };
}
