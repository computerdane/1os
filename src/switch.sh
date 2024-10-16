#!/usr/bin/env bash

sudo nixos-rebuild switch --impure --flake .#$1
