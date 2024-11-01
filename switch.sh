#!/usr/bin/env bash

sudo nixos-rebuild switch -v --flake .#$1
