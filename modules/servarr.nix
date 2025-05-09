{
  config,
  lib,
  nixpkgs-unstable,
  pkgs,
  ...
}:

let
  cfg = config.oneos.servarr;
  domain = "${cfg.subdomain}.${cfg.domain}";
in
{
  options.oneos.servarr =
    with lib;
    with types;
    {
      enable = mkEnableOption "servarr";
      subdomain = mkOption {
        type = str;
        default = "jellyseerr";
      };
      domain = mkOption {
        type = str;
        default = config.oneos.domains.default;
      };
    };

  # Use services from unstable
  disabledModules = [
    "services/networking/aria2.nix"
    "services/misc/prowlarr.nix"
    "services/misc/radarr.nix"
    "services/misc/sonarr.nix"
  ];
  imports = [
    "${nixpkgs-unstable}/nixos/modules/services/networking/aria2.nix"
    "${nixpkgs-unstable}/nixos/modules/services/misc/recyclarr.nix"
    "${nixpkgs-unstable}/nixos/modules/services/misc/servarr/prowlarr.nix"
    "${nixpkgs-unstable}/nixos/modules/services/misc/servarr/radarr.nix"
    "${nixpkgs-unstable}/nixos/modules/services/misc/servarr/sonarr.nix"
  ];

  config = lib.mkIf cfg.enable {
    # Use packages from unstable
    services.recyclarr.package = pkgs.unstable.recyclarr;
    services.prowlarr.package = pkgs.unstable.prowlarr;
    services.radarr.package = pkgs.unstable.radarr;
    services.sonarr.package = pkgs.unstable.sonarr;

    sops.secrets =
      let
        sopsFile = ../secrets/bludgeonder.yaml;
      in
      {
        aria2-rpc-secret = { inherit sopsFile; };
        servarr-api-key =
          {
            inherit sopsFile;
          }
          // (with config.services.recyclarr; {
            owner = user;
            inherit group;
          });
        radarr-env =
          {
            inherit sopsFile;
          }
          // (with config.services.radarr; {
            owner = user;
            inherit group;
          });
        sonarr-env =
          {
            inherit sopsFile;
          }
          // (with config.services.sonarr; {
            owner = user;
            inherit group;
          });
      };

    services.jellyseerr.enable = true;

    services.prowlarr.enable = true;

    services.radarr.enable = true;
    services.radarr.environmentFiles = [ config.sops.secrets.radarr-env.path ];

    services.sonarr.enable = true;
    services.sonarr.environmentFiles = [ config.sops.secrets.sonarr-env.path ];

    services.recyclarr.enable = true;
    services.recyclarr.configuration = {
      radarr.radarr = {
        api_key._secret = config.sops.secrets.servarr-api-key.path;
        base_url = "http://localhost:7878";
      };
      sonarr.sonarr = {
        api_key._secret = config.sops.secrets.servarr-api-key.path;
        base_url = "http://localhost:8989";
      };
    };

    # Torrent client in VPN network namespace
    services.aria2 = {
      enable = true;
      rpcSecretFile = config.sops.secrets.aria2-rpc-secret.path;
      settings = {
        enable-rpc = true;
        rpc-listen-all = true;
        dir = "/var/lib/aria2-downloads";
        disable-ipv6 = true;
        async-dns = false;
        show-console-readout = false;
        bt-detach-seed-only = true; # Don't count seeding towards max download count
        # seed-time = 24 * 60; # Seed for 1 day
        seed-time = 0; # Don't seed (fix this)
      };
      downloadDirPermission = "0775";
      openPorts = true;
    };
    systemd.services.aria2 = {
      after = [ "pvpn-netns.service" ];
      bindsTo = [ "pvpn-netns.service" ];
      serviceConfig.NetworkNamespacePath = "/run/netns/pvpn";
    };

    oneos.dynamic-dns.subdomains = [ cfg.subdomain ];
    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://[::1]:${toString config.services.jellyseerr.port}";
    };

  };
}
