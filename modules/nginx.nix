{ config, lib, ... }:

let
  cfg = config.oneos.nginx;
in
{
  options.oneos.nginx.enable = lib.mkEnableOption "nginx";

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80 # http
      443 # https
    ];

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts = lib.genAttrs config.oneos.domains.domains (name: {
        enableACME = true;
        forceSSL = true;
        locations."/".return = "404";
      });
    };
  };
}
