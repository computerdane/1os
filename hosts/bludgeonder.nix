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
    fabric-servers.vanilla = {
      enable = true;
      openFirewall = true;
      ops = [ "Dane47" ];
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
