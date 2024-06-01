# Syncthing and syncthingtray
args @ {
  inputs,
  outputs,
  personal-data,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  system,
  lib,
  config,
  ...
}: {
  # Syncthing's settings and folders are configured in NixOS config
  # TODO Make syncthing run as user service, even though settings get written by OS config.
  services.syncthing.enable = false;

  # Start tray as user service
  services.syncthing.tray = {
    # TODO actually use this eventually
    # On KDE, it launches the plasmoid automatically (how?)
    # On Hyprland, it seems to run in XWayland because it doesn't see the env variables.
    enable = false;
    command = "syncthingtray --wait";
    package = pkgs.syncthingtray;
  };

  #xdg.configFile."syncthingtray.ini".source = ./syncthingtray.ini;
}
