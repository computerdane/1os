{
  config,
  inputs,
  lib,
  pkgs-unstable,
  ...
}:

let
  cfg = config.oneos.ai;
in
{
  disabledModules = [ "services/misc/open-webui.nix" ];
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/open-webui.nix" ];

  options.oneos.ai =
    with lib;
    with types;
    {
      enable = mkEnableOption "ai";
      port = mkOption {
        type = port;
        default = 4141;
      };
      host = mkOption {
        type = str;
        default = "::1";
      };
      openFirewall = mkOption {
        type = bool;
        default = false;
      };
      environment = mkOption {
        type = attrsOf str;
        default = {
          ENV = "prod";
          WEBUI_NAME = "I <3 AI!";
        };
      };
      subdomain = mkOption {
        type = str;
        default = "ai";
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
      sops.secrets.open-webui-env = { };

      oneos.subdomains = [ cfg.subdomain ];

      services.open-webui = with cfg; {
        enable = true;
        package = pkgs-unstable.open-webui;
        inherit
          port
          host
          openFirewall
          environment
          ;
        environmentFile = config.sops.secrets.open-webui-env.path;
      };

      services.nginx = {
        virtualHosts.${domain} = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://[::1]:${toString config.services.open-webui.port}";
            proxyWebsockets = true;
          };
        };
      };
    };
}
