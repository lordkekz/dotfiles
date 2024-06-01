# Cursors using Hyprcursor and XCursor as fallback
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
}: let
in {
  imports = [
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
  ];

  programs.hyprcursor-phinger.enable = true;
  wayland.windowManager.hyprland.settings.env = [
    "HYPRCURSOR_THEME,phinger-cursors-light-hyprcursor"
    "HYPRCURSOR_SIZE,24"
  ];

  stylix.cursor = {
    name = "phinger-cursors-light";
    # provides "phinger-cursors" and "phinger-cursors-light"
    package = pkgs.phinger-cursors;
    size = 24;
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
  };
}
