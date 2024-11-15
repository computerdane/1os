{
  pkgs,
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
        ipv4 = fromIpv4Cidr "10.105.0.0/24";
        ipv6 = fromIpv6Cidr "2600:1700:591:3b3f::/64";
      };
      gateway = {
        ipv4 = pickIpv4 subnet.ipv4 1;
        ipv6 = pickIpv6 subnet.ipv6 "1";
      };
      dhcpRange.ipv4 = {
        start = pickIpv4 subnet.ipv4 50;
        end = pickIpv4 subnet.ipv4 150;
      };
    };
    wg.subnet = {
      ipv4 = fromIpv4Cidr "10.105.39.0/24";
      ipv6 = fromIpv6Cidr "2600:1700:591:3b3e::/64";
    };
    scott.subnet = {
      ipv4 = fromIpv4Cidr "172.31.0.0/16";
      ipv6 = fromIpv6Cidr "fd00:100::/32";
      ipv6-public = fromIpv6Cidr "2001:470:be1c::/48";
    };
  };
in
{
  options.oneos.gateway =
    with lib;
    with types;
    {
      enable = mkEnableOption "gateway";
      nameservers = mkOption {
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

    systemd.services.systemd-networkd.requiredBy = [ "dhcpcd.service" ];

    systemd.network = {
      networks = {
        "20-lan" = {
          name = "lan";
          networkConfig.Address = with ips.lan.gateway; [
            ipv4.cidr
            ipv6.cidr
          ];
        };
        "25-wg" = {
          name = "wg";
          routes =
            let
              mkRoute = src: dest: {
                routeConfig = {
                  PreferredSource = src.address;
                  Destination = dest.cidr;
                };
              };
              mkRoutes = src: dest: [
                (mkRoute src.ipv4 dest.ipv4)
                (mkRoute src.ipv6 dest.ipv6)
              ];
            in
            lib.flatten [
              (mkRoute ips.lan.gateway.ipv4 ips.wg.subnet.ipv4)
              (mkRoutes ips.lan.gateway ips.scott.subnet)
              (mkRoute ips.lan.gateway.ipv6 ips.scott.subnet.ipv6-public)
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
                  ipv6-public.cidr
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
        internalIPs = [
          ips.lan.subnet.ipv4.cidr
          ips.wg.subnet.ipv4.cidr
        ];
        externalInterface = "wan";
      };
      hostId = "c04107a1"; # required by ZFS to ensure that a pool isn't accidentally imported on a wrong machine
      dhcpcd = {
        enable = true;
        persistent = true;
        allowInterfaces = [ "wan" ];
        extraConfig = ''
          noipv6rs        # disable routing solicitation
          interface wan
            ipv6rs        # enable routing solicitation for wan
            ia_na 1       # request an IPv6 address
            ia_pd 2 lan/0 # request a PD
            ia_pd 3 wg/0  # request a PD
        '';
      };
    };

    services.resolved.enable = false;
    services.dnsmasq = {
      enable = true;
      settings = {
        server = cfg.nameservers;

        # If you want dnsmasq to listen for DHCP and DNS requests only on
        # specified interfaces (and the loopback) give the name of the
        # interface (eg eth0) here.
        # Repeat the line for more than one interface.
        #interface=
        # Or you can specify which interface _not_ to listen on
        except-interface = "wan";

        # Set the DHCP server to authoritative mode. In this mode it will barge in
        # and take over the lease for any client which broadcasts on the network,
        # whether it has a record of the lease or not. This avoids long timeouts
        # when a machine wakes up on a new network. DO NOT enable this if there's
        # the slightest chance that you might end up accidentally configuring a DHCP
        # server for your campus/company accidentally. The ISC server uses
        # the same option, and this URL provides more information:
        # http://www.isc.org/files/auth.html
        dhcp-authoritative = true;

        # Do router advertisements for all subnets where we're doing DHCPv6
        # Unless overridden by ra-stateless, ra-names, et al, the router
        # advertisements will have the M and O bits set, so that the clients
        # get addresses and configuration from DHCPv6, and the A bit reset, so the
        # clients don't use SLAAC addresses.
        enable-ra = true;

        dhcp-range = [
          # Do stateless DHCP, SLAAC, and generate DNS names for SLAAC addresses
          # from DHCPv4 leases.
          "::,constructor:lan,ra-stateless,ra-names"

          # Uncomment this to enable the integrated DHCP server, you need
          # to supply the range of addresses available for lease and optionally
          # a lease time. If you have more than one network, you will need to
          # repeat this for each network on which you want to supply DHCP
          # service.
          (with ips.lan.dhcpRange.ipv4; "${start.address},${end.address},12h")
        ];

        # Set the domain for dnsmasq. this is optional, but if it is set, it
        # does the following things.
        # 1) Allows DHCP hosts to have fully qualified domain names, as long
        #     as the domain part matches this setting.
        # 2) Sets the "domain" DHCP option thereby potentially setting the
        #    domain of all systems configured by DHCP
        # 3) Provides the domain part for "expand-hosts"
        domain = "one.lan";

        # Always set the name of the host with hardware address
        # 11:22:33:44:55:66 to be "fred"
        #dhcp-host=11:22:33:44:55:66,fred
        dhcp-host = [ "9c:6b:00:2f:0e:be,fishtank" ];

        # Never forward addresses in the non-routed address spaces.
        bogus-priv = true;

        # Uncomment this to filter useless windows-originated DNS requests
        # which can trigger dial-on-demand links needlessly.
        # Note that (amongst other things) this blocks all SRV requests,
        # so don't use it if you use eg Kerberos, SIP, XMMP or Google-talk.
        # This option only affects forwarding, SRV records originating for
        # dnsmasq (via srv-host= lines) are not suppressed by it.
        filterwin2k = true;
      };
    };

    services.openssh.ports = [ 105 ];

    boot.kernel.sysctl = {
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
    };

    system.stateVersion = lib.mkForce "23.05";
  };
}
