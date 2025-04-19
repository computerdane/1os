#!/usr/bin/env bash

nixos-rebuild switch -f default.nix -A $1 --target-host $2 --use-remote-sudo

