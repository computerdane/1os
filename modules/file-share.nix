{ config, lib, ... }:

let
  cfg = config.oneos.file-share;
in
{
  options.oneos.file-share =
    with lib;
    with types;
    {
      enable = lib.mkEnableOption "file-share";
      domain = mkOption {
        type = str;
        default = config.oneos.domains.default;
      };
      subdomain = mkOption {
        type = str;
        default = "f";
      };
      path = mkOption {
        type = str;
        default = "/nas/share";
      };
    };

  config =
    let
      domain = "${cfg.subdomain}.${cfg.domain}";
    in
    lib.mkIf cfg.enable {
      # services.diod = {
      #   enable = true;
      #   exports = [ "/nas/share" ];
      #   userdb = true;
      # };

      oneos.dynamic-dns.subdomains = [ cfg.subdomain ];

      services.nginx = {
        virtualHosts.${domain} = {
          enableACME = true;
          forceSSL = true;
          locations."/".root = cfg.path;
        };
      };
    };
}
