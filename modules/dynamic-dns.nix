{
  config,
  lib,
  pkgs,
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
        description = "Set DNS records for the root domains themselves";
        type = bool;
        default = false;
      };
      ipv4 = mkOption {
        description = "Set A records";
        type = bool;
        default = false;
      };
      subdomains = mkOption {
        description = "Set DNS records for these subdomains";
        type = listOf str;
        default = if cfg.root then [ ] else [ config.networking.hostName ];
      };
      domains = mkOption {
        description = "Set DNS records for these root domains";
        type = listOf str;
        default = config.oneos.domains.domains;
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
        (pkgs.lib1os.genDomains cfg.subdomains cfg.domains)
      ];
      apiTokenFile = config.sops.secrets.cloudflare-api-key.path;
    };

    # Give some time for the network to come online
    systemd.services.cloudflare-dyndns = {
      # preStart = "sleep 10";
      requires = [ "network-online.target" ];
    };
  };
}
