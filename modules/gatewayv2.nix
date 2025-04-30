{
  config,
  hosts,
  lib,
  ...
}:

let
  cfg = config.oneos.gatewayv2;
in
{
  options.oneos.gatewayv2 =
    with lib;
    let
      ipOption = {
        addr = mkOption { type = types.str; };
        len = mkOption { type = types.int; };
      };
    in
    {
      enable = mkEnableOption "gatewayv2";
      nameservers = mkOption {
        type = types.listOf types.str;
        default = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
      mac = {
        wan = mkOption { type = types.str; };
        lan = mkOption { type = types.str; };
      };
      lan = {
        ipv4 = ipOption;
        ipv6 = ipOption;
        dhcpRange = {
          minAddr = mkOption { type = types.str; };
          maxAddr = mkOption { type = types.str; };
        };
      };
      wireguardPeers = mkOption {
        default = [ ];
        type = types.listOf (
          types.submodule {
            options = {
              endpoint = mkOption { type = types.str; };
              publicKey = mkOption { type = types.str; };
              cidrs = mkOption { type = types.listOf types.str; };
            };
          }
        );
      };
      wireguardPort = mkOption {
        default = 51820;
        type = types.port;
      };
    };

  config = lib.mkIf cfg.enable (
    let
      toCidr = { addr, len }: "${addr}/${toString len}";
      isIpv6 = addr: lib.hasInfix ":" addr;
    in
    {

      sops.secrets.gateway-wireguard-key = {
        owner = "systemd-network";
        group = "systemd-network";
        sopsFile = ../secrets/bludgeonder.yaml;
      };

      boot.kernel.sysctl = {
        "net.ipv6.conf.all.forwarding" = 1;
        "net.ipv4.conf.all.forwarding" = 1;
      };

      systemd.network.links = {
        "10-wan" = {
          matchConfig.PermanentMACAddress = cfg.mac.wan;
          linkConfig.Name = "wan";
        };
        "20-lan" = {
          matchConfig.PermanentMACAddress = cfg.mac.lan;
          linkConfig.Name = "lan";
        };
      };

      networking.dhcpcd = {
        enable = true;
        persistent = true;
        allowInterfaces = [ "wan" ];
        extraConfig = ''
          noipv6rs        # disable routing solicitation
          interface wan
            ipv6rs        # enable routing solicitation for wan
            ia_na 1       # request an IPv6 address
            ia_pd 2 lan/0 # request a PD
        '';
      };
      systemd.services.systemd-networkd.requiredBy = [ "dhcpcd.service" ];

      systemd.network.networks."20-lan" = {
        name = "lan";
        DHCP = "no";
        dns = cfg.nameservers;
        networkConfig.Address = with cfg.lan; [
          (toCidr ipv4)
          (toCidr ipv6)
        ];
      };

      systemd.network.networks."25-wg" = {
        name = "wg";
        DHCP = "no";
        routes = lib.flatten (
          map (
            { cidrs, ... }:
            map (cidr: {
              PreferredSource = with cfg.lan; if isIpv6 cidr then ipv6.addr else ipv4.addr;
              Destination = cidr;
            }) cidrs
          ) cfg.wireguardPeers
        );
      };

      systemd.network.netdevs."25-wg" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg";
        };
        wireguardConfig = {
          ListenPort = cfg.wireguardPort;
          PrivateKeyFile = config.sops.secrets.gateway-wireguard-key.path;
        };
        wireguardPeers = map (
          {
            endpoint,
            publicKey,
            cidrs,
          }:
          {
            Endpoint = endpoint;
            PublicKey = publicKey;
            AllowedIPs = cidrs;
          }
        ) cfg.wireguardPeers;
      };

      networking.nat = {
        enable = true;
        internalIPs = [ (toCidr cfg.lan.ipv4) ];
        externalInterface = "wan";
      };

      networking.firewall.interfaces.wan.allowedUDPPorts = [ cfg.wireguardPort ];
      networking.firewall.trustedInterfaces = [ "lan" ];

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
            (with cfg.lan.dhcpRange; "${minAddr},${maxAddr},12h")
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
          dhcp-host =
            let
              hostsWithMac = lib.filterAttrs (name: value: builtins.hasAttr "mac" value) hosts;
            in
            lib.mapAttrsToList (name: { mac, ... }: "${mac},${name}") hostsWithMac;

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

      services.openssh.ports = [
        22
        105
      ];
      services.fail2ban.enable = true;

    }
  );
}
