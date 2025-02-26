{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.protonvpn;
in
{
  options.oneos.protonvpn.enable = lib.mkEnableOption "protonvpn";

  config = lib.mkIf cfg.enable {
    sops.secrets.protonvpn-wireguard-config = { };

    systemd.services."protonvpn-netns-interface" =
      let
        startScript = pkgs.writeShellApplication {
          name = "pvpn-up";
          runtimeInputs = with pkgs; [
            iproute2
            wireguard-tools
          ];
          text = ''
            ip netns add pvpn

            ip link add pvpn type wireguard
            ip link set pvpn netns pvpn
            ip -n pvpn address add 10.2.0.2/32 dev pvpn
            ip netns exec pvpn wg setconf pvpn "${config.sops.secrets.protonvpn-wireguard-config.path}"
            ip -n pvpn link set pvpn up
            ip -n pvpn link set lo up
            ip -n pvpn route add default dev pvpn

            mkdir -p /etc/netns/pvpn
            echo "nameserver 10.2.0.1" > /etc/netns/pvpn/resolv.conf
          '';
        };
        stopScript = pkgs.writeShellApplication {
          name = "pvpn-down";
          runtimeInputs = [ pkgs.iproute2 ];
          text = ''
            rm -rf /net/netns/pvpn

            ip -n pvpn route del default dev pvpn
            ip -n pvpn link del pvpn

            ip netns del pvpn
          '';
        };
      in
      {
        requires = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${startScript}/bin/pvpn-up";
          ExecStop = "${stopScript}/bin/pvpn-down";
        };
      };
  };
}
