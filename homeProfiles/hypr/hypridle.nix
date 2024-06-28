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

  potential-wallpaper-list = lib.attrValues outputs.assets.wallpapers;
  funny-locking = pkgs.writeShellApplication {
    name = "run-hyprlock-with-randomized-wallpaper";
    runtimeInputs = [];
    text = ''
      # Use shuf to pick a random file from the list
      SELECTED_FILE=$(shuf -e ${lib.escapeShellArgs potential-wallpaper-list} -n 1)

      # Overwrite wallpaper with the selected file
      cp -fv "$SELECTED_FILE" "/tmp/hyprlock-wallpaper.jpg"

      # Start Hyprlock unless running
      pidof hyprlock || "${hyprlock}"
    '';
  };
in {
  home.packages = [funny-locking];
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        ignore_dbus_inhibit = false;
        lock_cmd = "${funny-locking}/bin/run-hyprlock-with-randomized-wallpaper";
        unlock_cmd = "pkill -SIGUSR1 hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 295; # seconds
          on-timeout = ''${dunstify} -p -t 10000 -a hypridle "About to lock screen..." > /tmp/hypridle-dunstify-id'';
          on-resume = ''${dunstify} -C $(cat /tmp/hypridle-dunstify-id)'';
        }
        {
          timeout = 300; # seconds
          on-timeout = "loginctl lock-session";
          on-resume = "loginctl unlock-session";
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
