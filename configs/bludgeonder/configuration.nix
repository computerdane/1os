{
  config,
  lib,
  pkgs,
  thothub-lib,
  ...
}:

let
  rtspPort = 6767;
  rtmpsPort = 1936;

  mcPort = 52225;
  mcVoicePort = 53335;
  mcMapPort = 54445;
in
{
  imports = [ ./hardware-configuration.nix ];

  services.nginx.virtualHosts."watch-beta.nf6.sh" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://10.105.25.2:8096";
      proxyWebsockets = true;
    };
  };

  sops.secrets.bluemap-htpasswd = {
    owner = "nginx";
    sopsFile = ../../secrets/bludgeonder.yaml;
  };
  services.nginx.virtualHosts."danecraft.net" = {
    useACMEHost = "danecraft.net";
    forceSSL = true;
    locations."/map/" = {
      proxyPass = "http://10.105.25.2:${toString mcMapPort}/";
      proxyWebsockets = true;
      basicAuthFile = config.sops.secrets.bluemap-htpasswd.path;
    };
  };
  users.users.nginx.extraGroups = [ "acme" ];

  sops.secrets.knot-update-key = { };
  oneos.dns-update = {
    enable = true;
    servers."ns1.danecraft.net" = {
      keyFile = config.sops.secrets.knot-update-key.path;
      zone = "danecraft.net";
      acme = [ "danecraft.net" ];
      records = [
        {
          name = "danecraft.net";
          type = "A";
          dynamic = "ipv4";
        }
        {
          name = "danecraft.net";
          type = "AAAA";
          dynamic = "ipv6";
        }
        {
          name = "_minecraft._tcp.danecraft.net";
          type = "SRV";
          data = "0 5 ${toString mcPort} danecraft.net.";
        }
        {
          name = "lan.danecraft.net";
          type = "A";
          data = "10.105.25.2";
        }
        {
          name = "_minecraft._tcp.lan.danecraft.net";
          type = "SRV";
          data = "0 5 ${toString mcPort} lan.danecraft.net.";
        }
      ];
    };
  };

  networking.nat.forwardPorts = [
    {
      destination = "10.105.25.2:${toString mcPort}";
      proto = "tcp";
      sourcePort = mcPort;
    }
    {
      destination = "10.105.25.2:${toString mcPort}";
      proto = "udp";
      sourcePort = mcPort;
    }
    {
      destination = "10.105.25.2:${toString mcVoicePort}";
      proto = "udp";
      sourcePort = mcVoicePort;
    }
  ];

  oneos = {
    acme.enable = true;
    # acme.useStaging = true;
    dynamic-dns = {
      enable = true;
      root = true;
      ipv4 = true;
      subdomains = [ "watch-beta" ];
    };
    extra-users.enable = true;
    jellyfin = {
      enable = true;
      subdomain = "watch";
    };
    litellm.enable = false;
    nginx = {
      enable = true;
      root = true;
    };
    protonvpn.enable = true;
    servarr = {
      enable = true;
      subdomain = "request";
    };
    vault.enable = true;
    vintagestory-server = {
      enable = false;
      openFirewall = true;
      package = pkgs.unstable.vintagestory;
      settings = {
        WhitelistMode = 1;
        Password = "sex";
      };
    };
  };

  services.mediamtx = {
    enable = false;
    settings = {
      paths.all_others.source = "publisher";

      # RTSPS wasn't working with OBS, so I used RTMPS, but RTMPS wasn't working with MPV, so I also have an unencrypted RTSP endpoint for reading streams. Use the RTMPS endpoing for publishing.

      rtspAddress = ":${toString rtspPort}";

      rtmpEncryption = "strict";
      rtmpsAddress = ":${toString rtmpsPort}";
      rtmpServerKey = "/var/lib/acme/nf6.sh/key.pem";
      rtmpServerCert = "/var/lib/acme/nf6.sh/cert.pem";

      authInternalUsers = [
        {
          user = "any";
          permissions = [
            { action = "read"; }
            { action = "playback"; }
          ];
        }
        {
          user = "anon";
          pass = "argon2:$argon2id$v=19$m=4096,t=3,p=1$c2FsdEl0V2l0aFNhbHQ$QtG2udJ6X7BZ/glv5/6KmJeboeEs/iMqYOyMKMYiTpE";
          permissions = [ { action = "publish"; } ];
        }
      ];
    };
  };
  systemd.services.mediamtx.serviceConfig.Group = lib.mkForce "nginx";

  networking.firewall.allowedTCPPorts = [
    rtmpsPort
    rtspPort
    mcPort
  ];
  networking.firewall.allowedUDPPorts = [
    rtspPort
    mcPort
    mcVoicePort
  ];

  services.murmur = {
    enable = false;
    openFirewall = true;
  };

  oneos.gatewayv2 = {
    enable = true;
    mac = {
      wan = "00:8e:25:73:01:41";
      lan = "fc:aa:14:0e:54:c7";
      lan25g = "00:e0:4c:64:32:5d";
    };
    lan = {
      ipv4 = {
        addr = "10.105.0.1";
        len = 24;
      };
      ipv6 = {
        addr = "2600:1700:280:496f::1";
        len = 64;
      };
      ipv6Prefix = "2600:1700:280:496f::/64";
      dhcpRange = {
        offset = 50;
        size = 100;
      };
    };
    lan25g = {
      ipv4 = {
        addr = "10.105.25.1";
        len = 24;
      };
      ipv6 = {
        addr = "2600:1700:280:496e::1";
        len = 64;
      };
    };
    # wireguardPeers = thothub-lib.flatSelect "wireguardPeers" (
    #   builtins.attrValues (lib.filterAttrs (name: _: name != "dane") config.thots)
    # );
  };
}
