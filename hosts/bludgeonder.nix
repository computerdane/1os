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
    fabric-servers.main = {
      enable = true;
      openFirewall = true;
      mcVersion = "1.21.4";
      ops = [ "Dane47" ];
      mods = [
        "fabric-api"
        "no-chat-reports"
        "simple-voice-chat"
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
