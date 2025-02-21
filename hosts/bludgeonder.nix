{ ... }:

{
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
      version = "1.21.4";
      loader = "fabric";
      modrinthMods = [
        "fabric-api"
        "simple-voice-chat"
        "no-chat-reports"
      ];
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
      version = "1.20.1";
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

  oneos = {
    # acme.useStaging = true;
    # ai.enable = true;
    auto-update = {
      pull = true;
      push = true;
    };
    chatwick.enable = true;
    dynamic-dns = {
      enable = true;
      root = true;
      ipv4 = true;
    };
    # factorio-server.enable = true;
    # file-share.enable = true;
    gateway.enable = true;
    jellyfin = {
      enable = true;
      subdomain = "watch";
    };
    # livestream-server.enable = true;
    vault.enable = true;
  };
}
