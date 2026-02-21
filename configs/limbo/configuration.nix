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

  oneos = {
    desktop.enable = true;
    dynamic-dns.enable = true;
    extra-users.enable = true;
    gaming.enable = true;
    gpu-nvidia.enable = true;
  };

  services.flatpak.enable = true;

  services.minecraft-server = {
    enable = true;
    eula = true;
    jvmOpts = "-Xmx8G -Xms8G";
    package = pkgs.temurin-jre-bin;
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
