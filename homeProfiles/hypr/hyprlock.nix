# Config for Hyprlock lock screen
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
  inherit (lib) mapAttrsToList;

  rs = num: builtins.toString (builtins.floor num);

  monitors = {
    "eDP-1" = 1.6;
    "DP-1" = 2.0;
    "DP-2" = 1.6;
  };

  mkInputField = monitor: scale: {
    inherit monitor;
    size = "${rs (300 * scale)}, ${rs (40 * scale)}";
    position = "0, -${rs (80 * scale)}";
    dots_center = true;
    dots_size = 0.5; # Scale of input-field height, 0.2 - 0.8
    dots_spacing = 0.5;
    fade_on_empty = true;
    fade_timeout = 1; # Milliseconds before fade_on_empty is triggered.
    font_color = "rgb(40, 40, 40)";
    inner_color = "rgb(200, 200, 200)";
    outer_color = "rgba(120, 120, 120, 0.9)";
    outline_thickness = rs (1.5 * scale);
    placeholder_text = "<i>Start typing...</i>";
    fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
    capslock_color = "rgb(80, 128, 255)";
  };

  mkLabel = monitor: scale: {
    inherit monitor;
    text = "$TIME";
    font_family = "Inter";
    font_size = rs (150 * scale);

    position = "0, ${rs (175 * scale)}";

    valign = "center";
    halign = "center";

    shadow_passes = 3;
    shadow_size = rs (3 * scale);
  };

  mkBackground = monitor: scale: {
    inherit monitor;
    path = "/tmp/hyprlock-wallpaper.jpg";
    blur_size = rs (2.5 * scale);
    blur_passes = rs (1.5 * scale);
    noise = 0.075;
    contrast = 0.9;
    brightness = 0.9;
    vibrancy = 0.3;
    vibrancy_darkness = 0.0;
  };
in {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 300;
        hide_cursor = false;
      };

      background = mapAttrsToList mkBackground monitors;
      #input-field = mapAttrsToList mkInputField monitors;
      label = mapAttrsToList mkLabel monitors;
    };
  };
}
