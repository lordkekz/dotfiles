# Syncthing folders for Desktop systems.
{
  inputs,
  outputs,
  nixosProfiles,
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
    user = "hpreiser";
    userHome = "/home/${user}";
  in {
    enable = true;
    inherit user;
    dataDir = userHome + "/.syncthing"; # Default folder for new synced folders
    configDir = userHome + "/.config/syncthing"; # Folder for Syncthing's settings and keys

    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        #"Vortex" = {id = "DMEUMG6-WZUGJUH-5CY4EFH-2NNPNHN-HQBFKYA-WTK7240-5H5FFNH-3KHKYQO";};
        "KeksWork-Win11" = {id = "AZDY2X7-C6DWXZL-UY4X6BX-GFSXETR-VRGSLCI-KOYI43X-MQAKZBQ-VY4IUAH";};
      };
      folders = {
        "Documents" = {
          id = "a9t3y-uxeo6";
          path = userHome + "/Documents"; # Which folder to add to Syncthing
          devices = [
            # "Vortex"
            "KeksWork-Win11"
          ];
          # ignorePerms = false; # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
        };
        "Bilder" = {
          id = "jpcht-6wtcn";
          path = userHome + "/Pictures";
          devices = [
            # "Vortex"
            "KeksWork-Win11"
          ];
        };
        "Musik" = {
          id = "xligm-rbntn";
          path = userHome + "/Music";
          devices = [
            # "Vortex"
            "KeksWork-Win11"
          ];
        };
      };
    };
  };
}
