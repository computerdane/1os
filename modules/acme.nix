{
  config,
  lib,
  lib1os,
  ...
}:

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
    };

  config = lib.mkIf cfg.enable {
    sops.secrets.cloudflare-api-key = { };

    services.nginx.enable = true;

    security.acme = {
      acceptTerms = true;

      defaults = {
        email = "admin@${builtins.elemAt config.oneos.domains 0}";
        group = config.services.nginx.group;
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        environmentFile = config.sops.secrets.cloudflare-api-key.path;
      };

      certs =
        with lib;
        genAttrs (flatten [
          (if cfg.root then config.oneos.domains else [ ])
          (lib1os.genDomains cfg.subdomains config.oneos.domains)
        ]) (name: { });

      # Uncomment to use Let's Encrypt Staging Environment
      # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };
  };
}
