# My config for Walker, a Wayland-Native runner.
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
  mainBar = {
    layer = "top";
    position = "top";
    height = 30;

    modules-left = ["hyprland/workspaces" "hyprland/submap" "hyprland/language" "wlr/taskbar"];
    modules-center = ["hyprland/window" "custom/hello-from-waybar" "clock"];
    modules-right = ["bluetooth" "backlight"  "user" "cpu" "temperature" "battery"];

    "custom/hello-from-waybar" = {
      format = "hello {}";
      max-length = 40;
      interval = "once";
      exec = pkgs.writeShellScript "hello-from-waybar" ''
        echo "from within waybar"
      '';
    };
  };
in {
  programs.waybar = {
    enable = true;
    settings = {inherit mainBar;};
    style = lib.readFile ./waybar.css;
  };
}
