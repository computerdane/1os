{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.chatwick;
in
{
  options.oneos.chatwick =
    with lib;
    with types;
    {
      enable = mkEnableOption "chatwick";
      subdomain = mkOption {
        type = str;
        default = "chatwick";
      };
      domain = mkOption {
        type = str;
        default = config.oneos.domains.default;
      };
    };

  config =
    let
      domain = "${cfg.subdomain}.${cfg.domain}";
    in
    lib.mkIf cfg.enable {

      sops.secrets.openai-api-key = { };

      oneos.dynamic-dns.subdomains = [ cfg.subdomain ];

      systemd.services.chatwick = {
        environment = {
          PORT = "8414";
          OPENAI_API_KEY_FILE = config.sops.secrets.openai-api-key.path;
        };
        script = ''
          cd /run
          rm -rf chatwick
          git clone "https://github.com/computerdane/chatwick"
          cd chatwick
          nix run
        '';
        path = with pkgs; [
          git
          nix
        ];
      };

      services.nginx = {
        virtualHosts.${domain} = {
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://[::1]:${config.systemd.services.chatwick.environment.PORT}";
        };
      };

    };
}
