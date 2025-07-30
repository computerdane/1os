#!/usr/bin/env bash

nix flake update

cd configs
nix flake update

cd ../homeconfigs
nix flake update

cd ../pkgs
nix flake update
