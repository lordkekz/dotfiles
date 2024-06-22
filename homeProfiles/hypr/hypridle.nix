# Config for Hypridle, the idle deamon for Hyprland
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
  hyprlock = "${config.programs.hyprlock.package}/bin/hyprlock";
  dunstify = "${config.services.dunst.package}/bin/dunstify";
in {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        ignore_dbus_inhibit = false;
        lock_cmd = "pidof hyprlock || ${hyprlock}";
        unlock_cmd = "pkill -SIGUSR1 hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 290; # seconds
          on-timeout = ''${dunstify} -t 10000 -a hypridle "About to lock screen..."'';
        }
        {
          timeout = 300; # seconds
          on-timeout = "loginctl lock-session";
        }
        #{
        #  timeout = 600;
        #  on-timeout = "hyprctl dispatch dpms off";
        #  on-resume = "hyprctl dispatch dpms on";
        #}
      ];
    };
  };
}
