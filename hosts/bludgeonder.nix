{ ... }:

{
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
    fabric-servers.main =
      let
        voicePort = 25567;
      in
      {
        enable = true;
        mcVersion = "1.21.4";

        port = 25565;
        rconPort = 25566;
        openFirewall = true;
        openExtraUdpPorts = [ voicePort ];

        enableWhitelist = true;
        whitelist = [ "Dane47" ];

        ops = [ "Dane47" ];

        modrinthMods = [
          "fabric-api"
          "no-chat-reports"
          "simple-voice-chat"
        ];

        modConfigs = [
          {
            path = "voicechat/voicechat-server.properties";
            text = ''
              port=${toString voicePort}
            '';
          }
        ];
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
