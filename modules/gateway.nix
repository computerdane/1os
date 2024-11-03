{ config, lib, ... }:

let
  cfg = config.oneos.gateway;
in
{
  options.oneos.gateway =
    with lib;
    with types;
    {
      enable = mkEnableOption "gateway";
      lan = {
        ipv4 = {
          subnet = mkOption {
            type = str;
            default = "10.0.105.0/24";
          };
          address = mkOption {
            type = str;
            default = "10.0.105.1";
          };
          prefixLength = mkOption {
            type = int;
            default = 24;
          };
        };
        ipv6 = {
          address = mkOption {
            type = str;
            default = "fd00:da2e::1";
          };
        };
      };
      wireguard = {
        ipv4 = {
          subnet = mkOption {
            type = str;
            default = "10.0.39.0/24";
          };
        };
        ipv6 = {
          subnet = mkOption {
            type = str;
            default = "fd00:da2e:39::/64";
          };
        };
        port = mkOption {
          type = port;
          default = 50105;
        };
      };
      dns = mkOption {
        type = listOf str;
        default = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
    };

  config =
    let
      lanIpv4Cidr = with cfg.lan.ipv4; "${address}/${toString prefixLength}";
    in
    lib.mkIf cfg.enable {
      sops.secrets.gateway-wireguard-key = {
        owner = config.users.users.systemd-network.name;
        group = config.users.users.systemd-network.group;
      };

      systemd.network = {
        networks = {
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
              Address = [
                lanIpv4Cidr
                cfg.lan.ipv6.address
              ];
              DNS = cfg.dns;
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
          "25-wg" = {
            name = "wg";
            routes = [
              {
                routeConfig = {
                  PreferredSource = cfg.lan.ipv4.address;
                  Destination = cfg.wireguard.ipv4.subnet;
                };
              }
              {
                routeConfig = {
                  PreferredSource = cfg.lan.ipv6.address;
                  Destination = cfg.wireguard.ipv6.subnet;
                };
              }
            ];
          };
        };
        netdevs."25-wg" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "wg";
          };
          wireguardConfig = {
            ListenPort = cfg.wireguard.port;
            PrivateKeyFile = config.sops.secrets.gateway-wireguard-key.path;
          };
          wireguardPeers = [
            {
              wireguardPeerConfig = {
                AllowedIPs = with cfg.wireguard; [
                  ipv4.subnet
                  ipv6.subnet
                ];
                PublicKey = "W9WHvF9Z8DNpMHVgYfcvY/ep93iC/R4PJKcQr0ty3RA="; # schlaptop
              };
            }
            {
              wireguardPeerConfig = {
                AllowedIPs = with cfg.wireguard; [
                  ipv4.subnet
                  ipv6.subnet
                ];
                PublicKey = "H8tkZspaUWMvWz1XMjeEWIKlGTBT7jdZ29lvNiGUMAg="; # fone
              };
            }
          ];
        };
      };

      networking = {
        firewall = {
          interfaces = {
            lan.allowedUDPPorts = [
              53 # dns
              67 # dhcp
            ];
            wan.allowedUDPPorts = [ cfg.wireguard.port ];
          };
          trustedInterfaces = [ "wg" ];
        };
        nat = {
          enable = true;
          enableIPv6 = true;
          internalIPs = [
            cfg.lan.ipv4.subnet
            cfg.wireguard.ipv4.subnet
          ];
          internalIPv6s = [ cfg.wireguard.ipv6.subnet ];
          externalInterface = "wan";
        };
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
