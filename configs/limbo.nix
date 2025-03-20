{ ... }:

{
  oneos = {
    acme.enable = true;
    auto-update.pull = true;
    dynamic-dns.enable = true;
    gpu-nvidia.enable = true;
    jellyfin = {
      enable = true;
      subdomain = "watch-test";
    };
    mount-9p.enable = true;
    nginx.enable = true;
  };
}
