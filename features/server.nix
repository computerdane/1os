{ lib, ... }:

{
  networking = {
    firewall = {
      interfaces.lan.allowedUDPPorts = [
        53 # dns
        67 # dhcp
      ];
      trustedInterfaces = [ "pc" ];
    };
    nat = {
      enable = true;
      internalInterfaces = [ "lan" ];
      externalInterface = "wan";
    };
    interfaces = {
      lan.ipv4.addresses = [
        {
          address = "10.0.105.1";
          prefixLength = 24;
        }
      ];
      pc.ipv4.addresses = [
        {
          address = "10.0.105.10";
          prefixLength = 24;
        }
      ];
    };
    hosts = {
      "10.0.105.1" = [ "one.lan" ];
      "10.0.105.10" = [ "one.lan" ];
    };
    hostId = "c04107a1"; # required by ZFS to ensure that a pool isn't accidentally imported on a wrong machine
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      server = [
        "1.1.1.1"
        "1.0.0.1"
      ];

      # Set the domain for dnsmasq. this is optional, but if it is set, it
      # does the following things.
      # 1) Allows DHCP hosts to have fully qualified domain names, as long
      #     as the domain part matches this setting.
      # 2) Sets the "domain" DHCP option thereby potentially setting the
      #    domain of all systems configured by DHCP
      # 3) Provides the domain part for "expand-hosts"
      domain = "one.lan";

      dhcp-range = [
        # Do stateless DHCP, SLAAC, and generate DNS names for SLAAC addresses
        # from DHCPv4 leases.
        "::, ra-stateless, ra-names"

        # Uncomment this to enable the integrated DHCP server, you need
        # to supply the range of addresses available for lease and optionally
        # a lease time. If you have more than one network, you will need to
        # repeat this for each network on which you want to supply DHCP
        # service.
        "10.0.105.50,10.0.105.150,12h"
      ];

      # Always set the name of the host with hardware address
      # 11:22:33:44:55:66 to be "fred"
      #dhcp-host=11:22:33:44:55:66,fred
      dhcp-host = [ "9c:6b:00:2f:0e:be,pc" ];

      # If you want dnsmasq to listen for DHCP and DNS requests only on
      # specified interfaces (and the loopback) give the name of the
      # interface (eg eth0) here.
      # Repeat the line for more than one interface.
      #interface=
      # Or you can specify which interface _not_ to listen on
      except-interface = "wan";

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
}
