#!/usr/bin/env bash

home-manager build -f default.nix -A $1 && \
  nix-copy-closure --to $2 result && \
  ssh -t $2 "$(readlink result)/activate"
