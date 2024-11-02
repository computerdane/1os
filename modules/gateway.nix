{ config, lib, ... }:

let
  cfg = config.oneos.gateway;
in
{
  options.oneos.gateway.enable = lib.mkEnableOption "gateway";

  config = lib.mkIf cfg.enable {
    systemd.network.networks = {
      "10-wan" = {
        name = "wan";
        DHCP = "yes";
        networkConfig.IPv6AcceptRA = true;
        dhcpV6Config = {
          WithoutRA = "solicit";
          UseDNS = false;
        };
        ipv6AcceptRAConfig.UseDNS = false;
        dhcpV4Config.UseDNS = false;
      };
      "20-lan" = {
        name = "lan";
        DHCP = "no";
        networkConfig = {
          Address = "10.0.105.1/24";
          DNS = [
            "1.1.1.1"
            "1.0.0.1"
          ];
          DHCPServer = true;
          DHCPPrefixDelegation = true;
          IPv6SendRA = true;
          IPv6AcceptRA = false;
        };
        dhcpServerConfig.PoolOffset = 100;
        dhcpPrefixDelegationConfig = {
          UplinkInterface = "wan";
          Announce = "yes";
        };
      };
    };

    networking = {
      firewall = {
        interfaces.lan.allowedUDPPorts = [
          53 # dns
          67 # dhcp
        ];
        # trustedInterfaces = [ "pc" ];
      };
      nat = {
        enable = true;
        internalInterfaces = [ "lan" ];
        externalInterface = "wan";
      };
      hosts."10.0.105.1" = [ "one.lan" ];
      hostId = "c04107a1"; # required by ZFS to ensure that a pool isn't accidentally imported on a wrong machine
    };

    services.openssh.ports = [ 105 ];

    boot.kernel.sysctl = {
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
    };

    system.stateVersion = lib.mkForce "23.05";
  };
}
