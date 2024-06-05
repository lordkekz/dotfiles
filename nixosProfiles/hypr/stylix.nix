# Use stylix system-wide
args @ {
  inputs,
  outputs,
  nixosProfiles,
  lib,
  config,
  system,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  ...
}: let
in {
  imports = [
    inputs.stylix.nixosModules.stylix
    ../../stylix-base.nix
  ];

  stylix = {
    targets.plymouth.enable = false;
  };
}
