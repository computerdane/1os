#!/usr/bin/env bash

sudo nixos-rebuild switch -f default.nix -A $(hostname -s)
