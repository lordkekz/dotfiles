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
    height = 32;
    reload_style_on_change = true;

    modules-left = [
      "hyprland/workspaces"
      #"hyprland/submap"
      #"hyprland/language" # KB language
      #"wlr/taskbar"
      #"user" # Username and uptime
      "tray"
    ];
    modules-center = [
      "privacy"
      "hyprland/window"
    ];
    modules-right = [
      "pulseaudio"
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

    "pulseaudio" = {
      on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
    };

    "clock" = {
      interval = 1;
      format = "{:%F %T}"; # e.g. 2024-05-28 20:32:37
    };
  };
in {
  programs.waybar = {
    enable = true;
    systemd.enable = false;
    settings = {inherit mainBar;};
    style = lib.readFile ./waybar.css;
  };

  stylix.targets.waybar = {
    enableLeftBackColors = false;
    enableCenterBackColors = false;
    enableRightBackColors = false;
  };

  # Make waybar restart in case of crashes; using `systemctl stop` still works tho
  #systemd.user.services.waybar.Service.Restart = lib.mkForce "always";

  # Make waybar wanted by home-manager's `tray.target`
  #systemd.user.services.waybar.Install.WantedBy = ["tray.target"];
  #systemd.user.services.waybar.Unit.PartOf = ["tray.target"];
}
