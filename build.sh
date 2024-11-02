#!/usr/bin/env bash

nix build -v .#nixosConfigurations.$1.config.system.build.toplevel
