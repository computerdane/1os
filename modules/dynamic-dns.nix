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
      subdomains = mkOption {
        type = listOf str;
        default = [ config.networking.hostName ];
      };
    };

  config = lib.mkIf cfg.enable {
    sops.secrets.cloudflare-api-key = { };

    services.cloudflare-dyndns = {
      enable = true;
      ipv6 = true;
      ipv4 = false;
      domains = lib1os.genDomains cfg.subdomains config.oneos.domains;
      apiTokenFile = config.sops.secrets.cloudflare-api-key.path;
    };
  };
}
