# Stylix for home manager
args @ {
  inputs,
  outputs,
  homeProfiles,
  personal-data,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  system,
  lib,
  config,
  ...
}: {
  imports = [
    inputs.stylix.homeManagerModules.stylix
    ../../stylix-base.nix
  ];

  stylix.targets.kde.enable = false;
}
