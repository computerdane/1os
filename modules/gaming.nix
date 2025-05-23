{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.gaming;
in
{
  options.oneos.gaming.enable = lib.mkEnableOption "gaming";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };

    programs.gamescope.enable = true;

    environment.systemPackages = with pkgs; [
      protonup-qt
      r2modman
    ];
  };
}
