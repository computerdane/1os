{ config, pkgs, ... }:

let
  hostName = config.networking.hostName;
in
{
  systemd.services.auto-update-push = {
    path = with pkgs; [
      git
      nix
      openssh
    ];
    environment.GIT_SSH_COMMAND = "ssh -i /home/dane/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new";
    serviceConfig.RuntimeDirectory = "auto-update-push";
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
  };
}
