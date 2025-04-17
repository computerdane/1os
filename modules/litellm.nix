{
  config,
  lib,
  nixpkgs-unstable,
  pkgs,
  ...
}:

let
  cfg = config.oneos.litellm;
in
{
  imports = [ "${nixpkgs-unstable}/nixos/modules/services/misc/litellm.nix" ];

  options.oneos.litellm =
    with lib;
    with types;
    {
      enable = mkEnableOption "litellm";
      subdomain = mkOption {
        type = str;
        default = "llm";
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

      oneos.dynamic-dns.subdomains = [ cfg.subdomain ];

      users.users.litellm = {
        isSystemUser = true;
        group = "litellm";
      };
      users.groups.litellm = { };

      sops.secrets.litellm-environment = with config.users.users.litellm; {
        owner = name;
        inherit group;
      };

      systemd.services.litellm.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "litellm";
        Group = "litellm";
      };

      services.litellm = {
        enable = true;
        package = pkgs.unstable.litellm;
        port = 7773;
        environmentFile = config.sops.secrets.litellm-environment.path;
        settings.model_list = [
          {
            model_name = "gpt-3.5-turbo";
            litellm_params.model = "openai/gpt-3.5-turbo";
          }
          {
            model_name = "gpt-4";
            litellm_params.model = "openai/gpt-4";
          }
          {
            model_name = "gpt-4o";
            litellm_params.model = "openai/gpt-4o";
          }
          {
            model_name = "gemini-2.0-flash";
            litellm_params.model = "gemini/gemini-2.0-flash";
          }
          {
            model_name = "gemini-1.5-flash";
            litellm_params.model = "gemini/gemini-1.5-flash";
          }
          {
            model_name = "gemini-1.5-pro";
            litellm_params.model = "gemini/gemini-1.5-pro";
          }
        ];
      };

      services.nginx = {
        virtualHosts.${domain} = {
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://127.0.0.1:${toString config.services.litellm.port}";
        };
      };
    };
}
