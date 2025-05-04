{
  config,
  lib,
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
      ops = thothub-lib.toMinecraftOps (thothub-lib.flatSelect "minecraftAccounts" [ config.thots.dane ]);
      whitelist = thothub-lib.flatSelect "minecraftAccounts" (builtins.attrValues config.thots);
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
      ops = thothub-lib.toMinecraftOps (thothub-lib.flatSelect "minecraftAccounts" [ config.thots.dane ]);
      whitelist = thothub-lib.flatSelect "minecraftAccounts" (builtins.attrValues config.thots);
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
        addr = "2600:1700:280:496f::1";
        len = 64;
      };
      dhcpRange = {
        minAddr = "10.105.0.50";
        maxAddr = "10.105.0.150";
      };
    };
    wireguardPeers = thothub-lib.flatSelect "wireguardPeers" (
      builtins.attrValues (lib.filterAttrs (name: _: name != "dane") config.thots)
    );
  };
}
