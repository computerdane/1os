#!/usr/bin/env bash

sudo nixos-rebuild switch --flake .#$1
