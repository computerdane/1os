#!/usr/bin/env bash

sudo nixos-rebuild switch -L --flake .#$1
