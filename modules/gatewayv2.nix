{ config, lib, ... }:

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
        lan25g = mkOption { type = types.str; };
      };
      lan = {
        ipv4 = ipOption;
        ipv6 = ipOption;
        ipv6Prefix = mkOption { type = types.str; };
        dhcpRange = {
          offset = mkOption { type = types.int; };
          size = mkOption { type = types.int; };
        };
      };
      lan25g = {
        ipv4 = ipOption;
        ipv6 = ipOption;
      };
      wireguardPeers = mkOption {
        default = [ ];
        type = types.listOf (
          types.submodule {
            options = {
              Endpoint = mkOption { type = types.str; };
              PublicKey = mkOption { type = types.str; };
              AllowedIPs = mkOption { type = types.listOf types.str; };
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
        "21-lan25g" = {
          matchConfig.PermanentMACAddress = cfg.mac.lan25g;
          linkConfig.Name = "lan25g";
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
            ia_pd 3 lan25g/0
        '';
      };
      systemd.services.systemd-networkd.requiredBy = [ "dhcpcd.service" ];

      systemd.network.networks."20-lan" = {
        name = "lan";
        DHCP = "no";
        dns = cfg.nameservers;
        address = with cfg.lan; [
          (toCidr ipv4)
          (toCidr ipv6)
        ];
        networkConfig = {
          DHCPServer = "yes";
          IPv6SendRA = "yes";
        };
        dhcpServerConfig = with cfg.lan.dhcpRange; {
          PoolOffset = offset;
          PoolSize = size;
        };
        ipv6Prefixes = [
          {
            AddressAutoconfiguration = true;
            OnLink = true;
            Prefix = cfg.lan.ipv6Prefix;
          }
        ];
      };

      systemd.network.networks."21-lan25g" = {
        name = "lan25g";
        DHCP = "no";
        dns = cfg.nameservers;
        address = with cfg.lan25g; [
          (toCidr ipv4)
          (toCidr ipv6)
        ];
      };

      systemd.network.networks."25-wg" = {
        name = "wg";
        DHCP = "no";
        routes = lib.flatten (
          map (
            { AllowedIPs, ... }:
            map (cidr: {
              PreferredSource = with cfg.lan; if isIpv6 cidr then ipv6.addr else ipv4.addr;
              Destination = cidr;
            }) AllowedIPs
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
        wireguardPeers = cfg.wireguardPeers;
      };

      networking.nat = {
        enable = true;
        internalIPs = [
          (toCidr cfg.lan.ipv4)
          (toCidr cfg.lan25g.ipv4)
        ];
        externalInterface = "wan";
      };

      networking.firewall.interfaces.wan.allowedUDPPorts = [ cfg.wireguardPort ];
      networking.firewall.trustedInterfaces = [
        "lan"
        "lan25g"
      ];

      services.openssh.ports = [
        22
        105
      ];
      services.fail2ban.enable = true;

    }
  );
}
