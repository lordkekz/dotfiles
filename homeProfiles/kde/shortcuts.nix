# My shortcuts for KDE Plasma
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
}:
with lib; {
  programs.plasma.shortcuts = {
    "kwin"."Window Maximize" = mkForce "Meta+Up";
    "kwin"."Window Minimize" = mkForce "Meta+Down";
    "kwin"."Window Quick Tile Top" = mkForce "Meta+Shift+Up";
    "kwin"."Window Quick Tile Bottom" = mkForce "Meta+Shift+Down";
    "org.kde.spectacle.desktop"."RectangularRegionScreenShot" = mkForce ["Meta+Shift+Print" "Meta+Shift+S"];
  };
}
