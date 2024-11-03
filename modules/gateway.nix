{ config, lib, ... }:

let
  cfg = config.oneos.gateway;
in
{
  options.oneos.gateway.enable = lib.mkEnableOption "gateway";

  config = lib.mkIf cfg.enable {
    sops.secrets.gateway-wireguard-key = {
      owner = config.users.users.systemd-network.name;
      group = config.users.users.systemd-network.group;
    };

    systemd.network = {
      networks."25-wg" = {
        name = "wg";
        routes = [
          {
            routeConfig = {
              PreferredSource = "10.0.105.1";
              Destination = "10.0.36.0/24";
            };
          }
        ];
      };
      netdevs."25-wg" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg";
        };
        wireguardConfig = {
          ListenPort = 50105;
          PrivateKeyFile = config.sops.secrets.gateway-wireguard-key.path;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              AllowedIPs = [ "10.0.36.0/24" ];
              PublicKey = "W9WHvF9Z8DNpMHVgYfcvY/ep93iC/R4PJKcQr0ty3RA="; # schlaptop
            };
          }
        ];
      };
    };

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
        interfaces = {
          lan.allowedUDPPorts = [
            53 # dns
            67 # dhcp
          ];
          wan.allowedUDPPorts = [
            50105 # wireguard
          ];
        };
        trustedInterfaces = [ "wg" ];
      };
      nat = {
        enable = true;
        internalInterfaces = [
          "lan"
          "wg"
        ];
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
