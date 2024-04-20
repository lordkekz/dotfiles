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
        ".cache/flatpak"
        ".cache/nix"
        ".cache/thumbnails"
        ".cache/tealdeer"
        # Contains some KDE config and telemetry
        ".config/KDE"
        ".config/kde.org"
      ];
      files = [
        ".local/share/nix/repl-history"
        ".local/share/krunnerstaterc"
      ];
    };
  };

  # Persistent local data, e.g. Settings, Downloads folder, Browser data, Flatpaks
  fileSystems."/persist/local".neededForBoot = true;
  environment.persistence."/persist/local" = {
    hideMounts = true;
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/flatpak"
      "/var/lib/nixos"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];

    users.${username} = {
      directories = [
        ".config/discord"
        ".config/Element"
        ".config/kdeconnect" # KDEconnect, contains keys for paired phone
        ".config/lutris"
        ".config/microsoft-edge"
        ".config/obs-studio"
        ".config/obsidian"
        ".config/Podman Desktop"
        ".config/Signal"
        ".config/syncthing" # Syncthing settings, e.g. telemetry and web interface
        ".local/share/atuin" # Atuin shell history database, host_id and sync keys
        ".local/share/flatpak"
        ".local/share/kwalletd" # KWallet database, contains e.g. WiFi passwords
        ".local/share/lutris"
        ".local/share/PrismLauncher"
        ".local/share/Steam"
        ".syncthing-folders" # Default folder for new synced folders
        ".gnupg"
        ".jdks" # JDKs downloaded by IntellIJ IDEA
        ".m2" # Local Maven Repo
        ".mozilla/firefox"
        ".renpy"
        ".ssh"
        ".steam"
        ".thunderbird" # Thunderbird profiles, not config
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
