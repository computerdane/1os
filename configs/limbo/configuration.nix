{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  systemd.network.networks."20-lan" = {
    name = "enp3s0";
    DHCP = "no";
    gateway = [
      "10.105.25.1"
      "2600:1700:280:496e::1"
    ];
    networkConfig.Address = [
      "10.105.25.2/24"
      "2600:1700:280:496e::2/64"
    ];
  };

  oneos = {
    acme.enable = true;
    desktop.enable = true;
    dynamic-dns.enable = true;
    extra-users.enable = true;
    gaming.enable = true;
    gpu-nvidia.enable = true;
    jellyfin = {
      enable = true;
      openFirewall = true;
      subdomain = "watch-test";
    };
    mount-9p = {
      enable = true;
      host = "10.105.25.1";
    };
    nginx.enable = true;
    nixbuild.enable = true;
  };
}
