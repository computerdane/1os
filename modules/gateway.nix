{
  config,
  lib,
  lib1os,
  ...
}:

let
  cfg = config.oneos.gateway;

  ips = with lib1os.ip; {
    lan = rec {
      subnet = {
        ipv4 = toIpv4 [
          10
          105
          0
          0
        ] 24;
        ipv6 = toIpv6 [
          "fd00"
          "105"
        ] 64;
      };
      gateway = {
        ipv4 = pickIpv4 subnet.ipv4 1;
        ipv6 = pickIpv6 subnet.ipv6 "1";
      };
    };
    wg.subnet = {
      ipv4 = toIpv4 [
        10
        105
        39
        0
      ] 24;
      ipv6 = toIpv6 [
        "fd00"
        "105"
        "39"
      ] 64;
    };
    scott.subnet = {
      ipv4 = toIpv4 [
        172
        31
        0
        0
      ] 16;
      ipv6 = toIpv6 [
        "fd00"
        "100"
      ] 32;
    };
  };
in
{
  options.oneos.gateway =
    with lib;
    with types;
    {
      enable = mkEnableOption "gateway";
      dns = mkOption {
        type = listOf str;
        default = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
      wireguardPort = mkOption {
        type = port;
        default = 50105;
      };
    };

  config = lib.mkIf cfg.enable {
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
            Address = with ips.lan.gateway; [
              ipv4.cidr
              ipv6.cidr
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
          routes =
            let
              mkRoutes = src: dest: [
                {
                  routeConfig = {
                    PreferredSource = src.ipv4.address;
                    Destination = dest.ipv4.cidr;
                  };
                }
                {
                  routeConfig = {
                    PreferredSource = src.ipv6.address;
                    Destination = dest.ipv6.cidr;
                  };
                }
              ];
            in
            lib.flatten [
              (mkRoutes ips.lan.gateway ips.wg.subnet)
              (mkRoutes ips.lan.gateway ips.scott.subnet)
            ];
        };
      };
      netdevs."25-wg" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg";
        };
        wireguardConfig = {
          ListenPort = cfg.wireguardPort;
          PrivateKeyFile = config.sops.secrets.gateway-wireguard-key.path;
        };
        wireguardPeers =
          let
            mkAllowedIps =
              with lib1os.ip;
              octet:
              let
                quartet = toString octet;
              in
              [
                (toIpv4 (pickIpv4 ips.wg.subnet.ipv4 octet) 32).cidr
                (toIpv6 (pickIpv6 ips.wg.subnet.ipv6 quartet) 128).cidr
              ];
          in
          [
            {
              wireguardPeerConfig = {
                AllowedIPs = mkAllowedIps 100;
                PublicKey = "W9WHvF9Z8DNpMHVgYfcvY/ep93iC/R4PJKcQr0ty3RA="; # schlaptop
              };
            }
            {
              wireguardPeerConfig = {
                AllowedIPs = mkAllowedIps 101;
                PublicKey = "H8tkZspaUWMvWz1XMjeEWIKlGTBT7jdZ29lvNiGUMAg="; # fone
              };
            }
            {
              wireguardPeerConfig = {
                Endpoint = "thotlab.net:51820";
                AllowedIPs = with ips.scott.subnet; [
                  ipv4.cidr
                  ipv6.cidr
                ];
                PublicKey = "7Rbjel+ivF1LD76TfcYgYLyxhe89b3r7vlF3iG6dYE4="; # scott
              };
            }
          ];
      };
    };

    networking = {
      firewall = {
        interfaces.wan.allowedUDPPorts = [ cfg.wireguardPort ];
        trustedInterfaces = [
          "lan"
          "wg"
        ];
      };
      nat = {
        enable = true;
        enableIPv6 = true;
        internalIPs = [
          ips.lan.subnet.ipv4.cidr
          ips.wg.subnet.ipv4.cidr
        ];
        internalIPv6s = [ ips.wg.subnet.ipv6.cidr ];
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
