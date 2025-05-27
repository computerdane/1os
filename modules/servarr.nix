{
  config,
  lib,
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
    services.transmission = {
      enable = true;
      package = pkgs.unstable.transmission_4;
      settings = {
        bind-address-ipv4 = "10.2.0.2";
        rpc-bind-address = "10.105.1.2";
        rpc-whitelist = "10.105.*.*";
        download-dir = "/var/lib/torrent-downloads";
        ratio-limit-enabled = true;
        ratio-limit = 1.2;
        message-level = 3;
      };
      downloadDirPermissions = "775";
      openPeerPorts = true;
    };
    systemd.services.transmission = {
      after = [ "pvpn-netns.service" ];
      bindsTo = [ "pvpn-netns.service" ];
      serviceConfig = {
        NetworkNamespacePath = "/run/netns/pvpn";
        RestrictAddressFamilies = lib.mkForce [
          "AF_UNIX"
          "AF_INET"
        ];
      };
    };
    # systemd once again breaking something
    services.resolved.enable = false;
    environment.etc."resolv.conf".text = ''
      nameserver 1.1.1.1
      nameserver 1.0.0.1
    '';

    oneos.dynamic-dns.subdomains = [ cfg.subdomain ];
    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://[::1]:${toString config.services.jellyseerr.port}";
    };

  };
}
