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
    enable = true;
  };

  home.packages = [
    # An autotile script for Plasma 6 (even though it's still in libsForQt5)
    pkgs.libsForQt5.polonium
  ];
}
