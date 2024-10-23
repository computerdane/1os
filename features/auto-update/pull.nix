{ pkgs, ... }:

{
  systemd.services.auto-update-pull = {
    path = with pkgs; [
      git
      nixos-rebuild
    ];
    serviceConfig.RuntimeDirectory = "auto-update-pull";
    script = ''
      cd $RUNTIME_DIRECTORY
      git clone git@github.com:danerieber/1os.git
      cd 1os

      nixos-rebuild switch --flake .
      reboot now
    '';
    startAt = "*-*-* 04:20:00";
  };
}
