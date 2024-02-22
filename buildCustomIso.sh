#! /usr/bin/env bash
nix build -L -v .#nixosConfigurations.nixos-live-image.config.system.build.isoImage; tput bel
