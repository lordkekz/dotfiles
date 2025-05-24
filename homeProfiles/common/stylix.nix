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
    inputs.stylix.homeModules.stylix
    ../../stylix-base.nix
  ];

  # There are some specific activations in graphical homeProfiles (e.g. KDE)
}
