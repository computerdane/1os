#!/usr/bin/env bash

nix build .#nixosConfigurations.1os.config.system.build.toplevel --impure
