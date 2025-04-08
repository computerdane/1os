{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  oneos = {
    acme.enable = true;
    auto-update.pull = true;
    desktop.enable = true;
    dynamic-dns.enable = true;
    extra-users.enable = true;
    gaming.enable = true;
    gpu-nvidia.enable = true;
    # jellyfin = {
    #   enable = true;
    #   subdomain = "watch-test";
    # };
    mount-9p.enable = true;
    nginx.enable = true;
  };
}
