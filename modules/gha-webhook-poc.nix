{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.oneos.gha-webhook-poc;

  src = pkgs.fetchFromGitHub {
    owner = "computerdane";
    repo = "gha-webhook-poc";
    rev = "main";
    hash = "sha256-yA0xuKdX0ivt3FvYEiCgvEgfEHI1q+Lu+ZTVuLR2QnA=";
  };
in
{
  options.oneos.gha-webhook-poc = {
    enable = lib.mkEnableOption "gha-webhook-poc";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.gha-webhook-poc-listener = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.bun ];
      environment.PORT = toString cfg.port;
      script = ''
        cd "$(mktemp -d)"
        cp -r ${src}/* .

        bun i
        bun index.ts
      '';
      serviceConfig.DynamicUser = true;
    };

  };
}
