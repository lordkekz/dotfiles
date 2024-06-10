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
}: {
  programs.plasma.shortcuts = {
    "kwin"."Window Maximize" = "Meta+Up";
    "kwin"."Window Minimize" = "Meta+Down";
    "kwin"."Window Quick Tile Top" = "Meta+Shift+Up";
    "kwin"."Window Quick Tile Bottom" = "Meta+Shift+Down";
    "org.kde.spectacle.desktop"."RectangularRegionScreenShot" = ["Meta+Shift+Print" "Meta+Shift+S"];
  };
}
