{ pkgs, ... }:

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
    forge-servers.chp =
      let
        voicePort = 26002;
      in
      {
        enable = true;
        mcVersion = "1.20.1";
        javaPackage = pkgs.temurin-jre-bin-17;

        forgeJarUrl = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.3.0/forge-1.20.1-47.3.0-installer.jar";

        port = 26000;
        rconPort = 26001;
        openFirewall = true;
        openExtraUdpPorts = [ voicePort ];

        enableWhitelist = true;
        whitelist = [
          "Dane47"
          "Jehova"
        ];

        ops = [ "Dane47" ];

        modrinthModpack = "cave-horror-project-modpack";

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
