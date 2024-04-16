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
    "ActivityManager"."switch-to-activity-0ea01e9d-4522-405e-ad09-1a5d4e7b3669" = [];
    "kcm_touchpad"."Toggle Touchpad" = ["Meta+Ctrl+Zenkaku Hankaku" "Touchpad Toggle"];
    "kwin"."Window Maximize" = "Meta+Up";
    "kwin"."Window Minimize" = "Meta+Down";
    "kwin"."Window Quick Tile Top" = "Meta+Shift+Up";
    "kwin"."Window Quick Tile Bottom" = "Meta+Shift+Down";
    "kwin"."Invert" = "Meta+Ctrl+I";
    "kwin"."Invert Screen Colors" = [];
    "kwin"."InvertWindow" = "Meta+Ctrl+U";
    "kwin"."Move Tablet to Next Output" = [];
    "kwin"."Toggle" = [];
    "kwin"."ToggleMouseClick" = "Meta+*";
    "kwin"."TrackMouse" = [];
    "org.kde.spectacle.desktop"."RectangularRegionScreenShot" = ["Meta+Shift+Print" "Meta+Shift+S"];
    "org_kde_powerdevil"."Sleep" = ["Launch Media" "Sleep"];
  };
}
