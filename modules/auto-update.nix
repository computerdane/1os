{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.oneos.auto-update;

  hostName = config.networking.hostName;

  mkUpdateService =
    {
      name,
      path,
      script,
      startAt,
    }:
    {
      inherit path script startAt;
      environment.GIT_SSH_COMMAND = "ssh -i /home/dane/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new";
      serviceConfig = {
        Type = "oneshot";
        RuntimeDirectory = name;
      };
    };
in
{
  options.oneos.auto-update.push = lib.mkEnableOption "auto-update push";
  options.oneos.auto-update.pull = lib.mkEnableOption "auto-update pull";

  config.systemd.services = {
    auto-update-push = lib.mkIf cfg.push (mkUpdateService {
      name = "auto-update-push";
      path = with pkgs; [
        git
        nix
        openssh
      ];
      script = ''
        cd $RUNTIME_DIRECTORY
        git clone git@github.com:danerieber/1os.git
        cd 1os

        git config user.name "${hostName}"
        git config user.email "system@${hostName}"

        nix flake update
        git add .
        git commit -m "[auto-update] $(date -I)"
        git push
      '';
      startAt = "*-*-* 04:00:00";
    });
    auto-update-pull = lib.mkIf cfg.pull (mkUpdateService {
      name = "auto-update-pull";
      path = with pkgs; [
        git
        nixos-rebuild
        openssh
      ];
      script = ''
        cd $RUNTIME_DIRECTORY
        git clone git@github.com:danerieber/1os.git
        cd 1os

        nixos-rebuild switch --flake .
      '';
      startAt = "*-*-* 04:20:00";
    });
  };
}
