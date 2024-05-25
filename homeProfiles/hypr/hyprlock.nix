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
in {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 5;
      };

      background = [
        {
          path = "screenshot";
          blur_size = 5;
          blur_passes = 3;
          blur_noise = 0.03;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = true;
          #font_color = "rgb(202, 211, 245)";
          #inner_color = "rgb(255, 255, 255, 35)";
          #outer_color = "rgb(2)";
          outline_thickness = 0;
          placeholder_text = "";
        }
      ];
    };
  };
}
