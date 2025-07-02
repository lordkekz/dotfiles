#! /usr/bin/env nix-shell
#! nix-shell -p jq -i bash

# shellcheck shell=bash

outfile=$(mktemp /tmp/system-derivations.XXXX)
printf "Outfile: %s\n" "$outfile"
attr_names=$(nix eval --json .#nixosConfigurations --apply builtins.attrNames | jq '.[]')
echo "$attr_names" | while read -r conf_name; do
    nix eval ".#nixosConfigurations.${conf_name}.config.system.build.toplevel" | \
      grep -o -E '/nix/store/.*\.drv' >> "$outfile"
done
