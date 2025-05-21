{ config, lib, ... }:

let
  cfg = config.oneos.fossai;
in
{
  options.oneos.fossai.enable = lib.mkEnableOption "fossai";

  config = lib.mkIf cfg.enable {

    sops.secrets.fossai-config = {
      owner = "fossai";
      group = "fossai";
      sopsFile = ../secrets/bludgeonder.yaml;
    };

    services.nginx = {
      virtualHosts."fossai-backend.nf6.sh" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://[::1]:${config.services.fossai.settings.PORT}";
        };
      };
      virtualHosts."fossai.nf6.sh" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://[::1]:${toString config.services.fossai.frontendPort}";
        };
      };
    };

    services.fossai = {
      enable = true;
      withPostgres = true;
      backendBaseUrl = "https://fossai-backend.nf6.sh";
      settings = {
        PRIVATE_CONFIG_FILE = config.sops.secrets.fossai-config.path;
        OPENAI_BASE_URL = "http://localhost:${toString config.services.litellm.port}";
        CORS_ORIGIN = "https://fossai.nf6.sh";
        PORT = "3055";
      };
    };

    oneos.dynamic-dns.subdomains = [
      "fossai-backend"
      "fossai"
    ];

  };
}
