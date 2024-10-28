{ pkgs, ... }:

import ./base.nix {
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
}
