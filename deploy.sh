#!/usr/bin/env bash

nix build .#nixosConfigurations.server.config.system.build.toplevel -o release-server && \
  nix copy --to ssh://10.0.105.1:105 release-server && \
  ssh -p 105 10.0.105.1 "$(readlink release-server)/bin/switch-to-configuration switch"
