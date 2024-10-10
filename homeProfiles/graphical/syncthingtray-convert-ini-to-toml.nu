#!/usr/bin/env nu

let groups = open syncthingtray.ini --raw | lines | split list "" | each {|x| {name: ($x | first | str substring 1..($x | first | str length | $in - 1)), value: ($x | skip 1) }}
let parsed = $groups | upsert value {|g| $g.value | each {|x| {name: ($x | str substring 0..($x | str index-of "=")), value: ($x | str substring ($x | str index-of "=" | $in + 1).. | str trim --char "\"") }} | transpose -ird} | transpose -ird
let toml = $parsed | to toml;
let nixVal = nix-instantiate --argstr "arg" ($toml) --eval --expr "{arg}: builtins.fromTOML arg";

print $nixVal
