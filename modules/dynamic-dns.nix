{
  config,
  lib,
  lib1os,
  ...
}:

let
  cfg = config.oneos.dynamic-dns;
in
{
  options.oneos.dynamic-dns =
    with lib;
    with types;
    {
      enable = mkEnableOption "dynamic-dns";
      root = mkOption {
        type = bool;
        default = false;
      };
      ipv4 = mkOption {
        type = bool;
        default = false;
      };
      subdomains = mkOption {
        type = listOf str;
        default = if cfg.root then [ ] else [ config.networking.hostName ];
      };
      domains = mkOption {
        type = listOf str;
        default = config.oneos.domains;
      };
    };

  config = lib.mkIf cfg.enable {
    sops.secrets.cloudflare-api-key = { };

    services.cloudflare-dyndns = {
      enable = true;
      ipv6 = true;
      ipv4 = cfg.ipv4;
      domains = lib.flatten [
        (if cfg.root then cfg.domains else [ ])
        (lib1os.genDomains cfg.subdomains cfg.domains)
      ];
      apiTokenFile = config.sops.secrets.cloudflare-api-key.path;
    };
  };
}
