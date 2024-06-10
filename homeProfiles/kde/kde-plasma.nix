# My config for KDE Plasma 6
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
    homeProfiles.graphical
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  programs.plasma = {
    enable = false;
  };
}
