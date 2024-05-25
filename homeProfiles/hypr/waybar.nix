# My config for Waybar
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

    modules-left = [
      "hyprland/workspaces"
      "hyprland/submap"
      #"hyprland/language" # KB language
      "wlr/taskbar"
      #"user" # Username and uptime
      "tray"
    ];
    modules-center = [
      "privacy"
      "hyprland/window"
    ];
    modules-right = [
      "bluetooth"
      "backlight"
      "network"
      "ram"
      #"load"
      "cpu"
      "temperature"
      "battery"
      "clock"
    ];
  };
in {
  programs.waybar = {
    enable = true;
    settings = {inherit mainBar;};
    #style = lib.readFile ./waybar.css;
  };
}
