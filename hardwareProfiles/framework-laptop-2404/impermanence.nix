{
  inputs,
  outputs,
  hardwareProfiles,
  personal-data,
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}: let
  inherit (personal-data.data.home) username;
in {
  imports = [inputs.impermanence.nixosModules.impermanence];

  # Persistent but ephemeral data, e.g. logs, VMs and containers, caches
  fileSystems."/persist/ephemeral".neededForBoot = true;
  environment.persistence."/persist/ephemeral" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/systemd/coredump"
    ];
    files = [
    ];
    users.${username} = {
      directories = [
        ".cache/fontconfig"
        ".cache/thumbnails"
        ".config/KDE"
        ".config/kde.org"
        ".config/kdeconnect"
      ];
    };
  };

  # Persistent local data, e.g. Settings, Downloads folder, Browser data, Flatpaks
  fileSystems."/persist/local".neededForBoot = true;
  environment.persistence."/persist/local" = {
    hideMounts = true;
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];

    users.${username} = {
      directories = [
        ".cache/nix"
        ".cache/tealdeer"
        ".config/discord"
        ".config/Element"
        ".config/lutris"
        ".config/microsoft-edge"
        ".config/obs-studio"
        ".config/obsidian"
        ".config/Podman Desktop"
        ".config/Signal"
        # ".config/syncthing" or ".syncthing" # contains index db
        ".gnupg"
        ".jdks" # JDKs downloaded by IntellIJ IDEA
        ".m2" # Local Maven Repo
        ".mozilla/firefox"
        ".renpy"
        ".ssh"
        ".steam"
        ".thunderbird"
        "Desktop"
        "Downloads"
        "Games"
      ];
    };
  };

  # Persistent roaming data, e.g. Syncthing folders
  fileSystems."/persist/roaming".neededForBoot = true;
  environment.persistence."/persist/roaming" = {
    hideMounts = true;
    users.${username} = {
      directories = [
        "Documents"
        "git"
        "Music"
        "Obsidian Vault"
        "Pictures"
        "Szechuan Sauce"
        "Videos"
      ];
    };
  };
}
