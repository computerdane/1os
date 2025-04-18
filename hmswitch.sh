#!/usr/bin/env bash

home-manager switch -f default.nix -A $(whoami)@$(hostname -s)
