#!/usr/bin/env bash

nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager 
nix-channel --add https://nixos.org/channels/nixos-24.11 nixpkgs 
nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs-unstable 
nix-channel --add https://github.com/nix-community/plasma-manager/archive/trunk.tar.gz plasma-manager 
nix-channel --add https://github.com/Mic92/sops-nix/archive/master.tar.gz sops-nix 
nix-channel --update
