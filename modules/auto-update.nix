{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.oneos.auto-update;
in
{
  options.oneos.auto-update.enable = lib.mkEnableOption "auto-update";

  config.systemd.services.auto-update = lib.mkIf cfg.enable {
    serviceConfig = {
      Type = "oneshot";
      RuntimeDirectory = "auto-update";
    };
    path = with pkgs; [
      bash
      git
      nix
      nixos-rebuild
    ];
    script = ''
      cd $RUNTIME_DIRECTORY
      git clone https://github.com/computerdane/1os.git
      cd 1os
      git checkout no-flakes
      ./update.sh
      nixos-rebuild switch -f default.nix -A ${config.networking.hostName}
    '';
    startAt = "*-*-* 04:00:00";
  };
}
