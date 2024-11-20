{
  config,
  lib,
  pkgs-bop,
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
      port = mkOption {
        type = port;
        default = 8085;
      };
      musicPath = mkOption {
        type = str;
        default = "/nas/hl/music";
      };
      authorizedKeys = mkOption {
        type = listOf str;
        default = [ ];
      };
    };

  config =
    let
      domain = "${cfg.subdomain}.${cfg.domain}";
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

      users.groups.bop = { };
      users.users.bop = {
        isNormalUser = true;
        home = cfg.musicPath;
        homeMode = "777";
        group = "bop";
        openssh.authorizedKeys.keys = cfg.authorizedKeys;
      };

      networking.firewall.allowedTCPPorts = [ cfg.port ];

      systemd.services.bop-api = {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs-bop.server-api ];
        script = ''
          bop-api listen "${cfg.musicPath}" "https://${domain}/" -p ${toString cfg.port}
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
