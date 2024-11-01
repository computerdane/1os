{ config, lib, ... }:

let
  cfg = config.oneos.gateway;
in
{
  options.oneos.gateway.enable = lib.mkEnableOption "gateway";

  config = lib.mkIf cfg.enable {
    systemd.network.enable = lib.mkForce false;
    networking.useNetworkd = lib.mkForce false;

    systemd.network.networks = {
      "10-wan" = {
        name = "wan";
        DHCP = "yes";
        networkConfig = {
          # The below setting is optional, to also assign an address in the delegated prefix
          # to the upstream interface. If not necessary, then comment out the line below and
          # the [DHCPPrefixDelegation] section.
          DHCPPrefixDelegation = true;

          # If the upstream network provides Router Advertisement with Managed bit set,
          # then comment out the line below and WithoutRA= setting in the [DHCPv6] section.
          # IPv6AcceptRA = false;
        };
        dhcpV6Config = {
          WithoutRA = "solicit";
        };
        dhcpPrefixDelegationConfig = {
          UplinkInterface = ":self";
          SubnetId = 0;
          Announce = "no";
        };
      };
      "10-lan" = {
        name = "lan";
        DHCP = "no";
        networkConfig = {
          Address = "10.0.105.1/24";

          DHCPPrefixDelegation = true;
          IPv6SendRA = true;

          # It is expected that the host is acting as a router. So, usually it is not
          # necessary to receive Router Advertisement from other hosts in the downstream network.
          IPv6AcceptRA = false;
        };
        dhcpPrefixDelegationConfig = {
          UplinkInterface = "wan";
          SubnetId = 1;
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
      interfaces = {
        lan.ipv4.addresses = [
          {
            address = "10.0.105.1";
            prefixLength = 24;
          }
        ];
      };
      dhcpcd = {
        persistent = true;
        allowInterfaces = [ "wan" ];
        extraConfig = ''
          noipv6rs        # disable routing solicitation
          interface wan
            ipv6rs        # enable routing solicitation for wan
            ia_na 1       # request an IPv6 address
            ia_pd 2 lan/0 # request a PD and assign it to lan
            ia_pd 3 pc/0  # request a PD and assign it to pc
        '';
      };
    };

    services.resolved.enable = false; # conflicts with dnsmasq
    services.dnsmasq = {
      enable = true;
      settings = {
        server = [
          "1.1.1.1"
          "1.0.0.1"
        ];

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
          "10.0.105.50,10.0.105.150,12h"
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

        # Never forward plain names (without a dot or domain part)
        domain-needed = true;

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
