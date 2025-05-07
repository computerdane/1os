{ config, lib, ... }:

let
  cfg = config.oneos.jellyreq;
in
{
  options.oneos.jellyreq.enable = lib.mkEnableOption "jellyreq";

  config = lib.mkIf cfg.enable {

    sops.secrets.aria2-rpc-secret.sopsFile = ../secrets/bludgeonder.yaml;

    # Torrent client in VPN network namespace
    services.aria2 = {
      enable = true;
      rpcSecretFile = config.sops.secrets.aria2-rpc-secret.path;
      settings = {
        enable-rpc = true;
        rpc-listen-all = true;
        disable-ipv6 = true;
        async-dns = false;
        show-console-readout = false;
      };
    };
    systemd.services.aria2 = {
      after = [ "pvpn-netns.service" ];
      bindsTo = [ "pvpn-netns.service" ];
      serviceConfig.NetworkNamespacePath = "/run/netns/pvpn";
    };

    services.jellyseerr.enable = true;
    services.prowlarr.enable = true;
    services.radarr.enable = true;

  };
}
