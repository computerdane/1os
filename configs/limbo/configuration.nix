{
  config,
  pkgs,
  lib,
  ...
}:

let
  port = 25565;
  vcPort = 24454;
in
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

  sops.secrets.knot-update-key = { };

  security.acme.acceptTerms = true;

  oneos = {
    desktop.enable = true;
    dynamic-dns.enable = true;
    extra-users.enable = true;
    gaming.enable = true;
    gpu-nvidia.enable = true;

    dns-update = {
      enable = true;
      servers."ns1.nix.gdn" = {
        keyFile = config.sops.secrets.knot-update-key.path;
        zone = "nix.gdn";
        acme = [ "mc.nix.gdn" ];
        records = [
          {
            name = "mc.nix.gdn";
            type = "A";
            dynamic = "ipv4";
          }
          {
            name = "mc.nix.gdn";
            type = "AAAA";
            dynamic = "ipv6";
          }
          {
            name = "_minecraft._tcp.nix.gdn";
            type = "SRV";
            data = "0 5 52255 mc.nix.gdn.";
            ttl = 3600;
          }
          {
            name = "_minecraft._tcp.mc.nix.gdn";
            type = "SRV";
            data = "0 5 52255 mc.nix.gdn.";
            ttl = 3600;
          }
        ];
      };
    };
  };

  services.flatpak.enable = true;

  services.minecraft-server = {
    enable = true;
    eula = true;
    jvmOpts = "-Xms5G -Xmx5G";
    package = pkgs.javaPackages.compiler.temurin-bin.jre-25;
  };

  systemd.services.minecraft-server =
    let
      cfg = config.services.minecraft-server;
    in
    {
      serviceConfig = {
        ExecStart = lib.mkForce "${cfg.package}/bin/java ${cfg.jvmOpts} -jar server.jar nogui";
      };
    };

  users.users.minecraft.homeMode = "770";
  users.users.dane.extraGroups = [ "minecraft" ];

  networking.firewall =
    let
      ports = [
        port
        vcPort
      ];
    in
    {
      allowedUDPPorts = ports;
      allowedTCPPorts = ports;
    };
}
