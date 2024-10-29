#!/usr/bin/env bash

BUILD_DIR="./result-$1"

nix build ".#nixosConfigurations.$1.config.system.build.toplevel" -o "$BUILD_DIR" && \
  nix copy --to "ssh://$2" "$BUILD_DIR" -v && \
  ssh -t "$2" "sudo $(readlink "$BUILD_DIR")/bin/switch-to-configuration switch"
