# Syncthing folders for Desktop systems.
{
  inputs,
  outputs,
  nixosProfiles,
  personal-data,
  lib,
  config,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  ...
}: {
  # Syncthing ports:
  # 8384 for remote access to GUI (not enabled because this is targeting graphical desktops)
  # 22000 TCP and/or UDP for sync traffic
  # 21027/UDP for discovery
  # source: https://docs.syncthing.net/users/firewall.html
  networking.firewall.allowedTCPPorts = [22000];
  networking.firewall.allowedUDPPorts = [22000 21027];

  # Actual configuration
  services.syncthing = let
    user = personal-data.data.home.username;
    userHome = config.users.users.${user}.home;
  in {
    enable = true;
    inherit user;
    dataDir = userHome + "/.syncthing-folders"; # Default folder for new synced folders
    configDir = userHome + "/.config/syncthing"; # Folder for Syncthing's settings and keys

    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI
    settings = personal-data.data.home.syncthing.settings userHome;
  };
}
