#!/bin/sh
nix-channel --update && nixos-rebuild switch
