{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.bop;
in
{
  options.oneos.bop =
    with lib;
    with types;
    {
      enable = mkEnableOption "bop";
      domain = mkOption {
        type = str;
        default = config.oneos.domains.default;
      };
      subdomain = mkOption {
        type = str;
        default = "bop";
      };
      finderPort = mkOption {
        type = port;
        default = 8085;
      };
      musicPath = mkOption {
        type = str;
        default = "/nas/hl/music";
      };
    };

  config =
    let
      domain = "${cfg.subdomain}.${cfg.domain}";

      bopFinder = pkgs.writeShellApplication {
        name = "bop-finder";
        runtimeInputs = with pkgs; [
          gawk
          fd
        ];
        text = ''
          cd "${cfg.musicPath}"
          fd -t f "$(echo "$*" | tr -d "-")" | awk '{print "https://${domain}/" $0}'
        '';
      };
    in
    lib.mkIf cfg.enable {

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

      networking.firewall.allowedTCPPorts = [ cfg.finderPort ];

      systemd.services.bop = {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.nmap ];
        script = ''
          ncat -l ${toString cfg.finderPort} -k -c "xargs -n1 ${bopFinder}/bin/bop-finder"
        '';
        serviceConfig.DynamicUser = true;
      };

      services.nginx = {
        virtualHosts.${domain} = {
          enableACME = true;
          forceSSL = true;
          locations."/".root = cfg.musicPath;
        };
      };

    };
}
