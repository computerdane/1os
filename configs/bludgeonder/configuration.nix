{
  config,
  pkgs,
  thothub-lib,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  oneos = {
    acme.enable = true;
    # acme.useStaging = true;
    dynamic-dns = {
      enable = true;
      root = true;
      ipv4 = true;
    };
    extra-users.enable = true;
    jellyfin = {
      enable = true;
      subdomain = "watch";
    };
    litellm.enable = true;
    mount-9p = {
      enable = true;
      isHost = true;
    };
    nginx = {
      enable = true;
      root = true;
    };
    nixbuild.enable = true;
    protonvpn.enable = true;
    vault.enable = true;
    vintagestory-server = {
      enable = true;
      openFirewall = true;
      package = pkgs.unstable.vintagestory;
      settings = {
        WhitelistMode = 1;
        Password = "sex";
      };
    };
  };

  services.mc-quick.main =
    let
      port = 25000;
      rconPort = 25001;
      voicePort = 25002;
    in
    {
      inherit port rconPort;
      enable = true;
      acceptEula = true;
      autoStart = true;
      mcVersion = "1.21.4";
      loader = "fabric";
      modrinthMods = [
        "fabric-api"
        "simple-voice-chat"
        "no-chat-reports"
      ];
      ops = thothub-lib.toMinecraftOps (thothub-lib.flattenMinecraftAccounts [ config.thots.dane ]);
      whitelist = thothub-lib.flattenMinecraftAccounts (builtins.attrValues config.thots);
      enableWhitelist = true;
      files = [
        {
          path = "config/voicechat/voicechat-server.properties";
          text = ''
            port=${toString voicePort}
          '';
        }
      ];
    };

  services.mc-quick.chp =
    let
      port = 26000;
      rconPort = 26001;
      voicePort = 26002;
    in
    {
      inherit port rconPort;
      enable = true;
      acceptEula = true;
      mcVersion = "1.20.1";
      loader = "forge";
      modrinthModpack = "cave-horror-project-modpack";
      ops = [
        {
          uuid = "6cfede5c-8117-4673-bd7d-0a17bbab69e2";
          name = "Dane47";
          level = 4;
          bypassesPlayerLimit = true;
        }
      ];
      enableWhitelist = true;
      files = [
        {
          path = "config/voicechat/voicechat-server.properties";
          text = ''
            port=${toString voicePort}
          '';
        }
      ];
      openFirewall = true;
      openFirewallExtraPorts = [ voicePort ];
    };

  services.murmur = {
    enable = true;
    openFirewall = true;
  };

  oneos.gatewayv2 = {
    enable = true;
    mac = {
      wan = "00:8e:25:73:01:41";
      lan = "fc:aa:14:0e:54:c7";
    };
    lan = {
      ipv4 = {
        addr = "10.105.0.1";
        len = 24;
      };
      ipv6 = {
        addr = "2600:1700:591:3b3e::1";
        len = 64;
      };
      dhcpRange = {
        minAddr = "10.105.0.50";
        maxAddr = "10.105.0.150";
      };
    };
    wireguardPeers = [
      {
        endpoint = "thotlab.net:51820";
        publicKey = "7Rbjel+ivF1LD76TfcYgYLyxhe89b3r7vlF3iG6dYE4=";
        cidrs = [
          "172.31.0.0/16"
          "fd00:100::/32"
          "2001:470:be1c::/48"
        ];
      }
    ];
  };
}
