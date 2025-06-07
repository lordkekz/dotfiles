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
        ".config/carapace"
        ".config/nushell"
        ".config/VSCodium"
        ".local/share/kactivitymanagerd"
        ".local/share/direnv/allow"
        # Avoid re-indexing KDE's baloo file index
        ".local/share/baloo"

        ".cache/bat"
        ".cache/bookmarksrunner"
        ".cache/fontconfig"
        ".cache/flatpak"
        ".cache/nix"
        ".cache/tealdeer"
        ".cache/thumbnails"
        # Actually I'd rather only persist ".cache/JetBrains/IntelliJIdea2024.1/plugins" because it contains IdeaVim
        # But I don't want to change it for every IntelliJ update.
        ".cache/JetBrains"
        # Contains some KDE config and telemetry
        ".config/KDE"
        ".config/kde.org"
      ];
      files = [
        ".config/birdtray-config.json"
        ".config/bluedevilglobalrc"
        ".config/kcminputrc" # Contains touchpad config
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
      "/var/db/sudo/lectured"

      "/var/lib/fprint"
      "/var/lib/cups"
      "/var/lib/incus"
      "/var/lib/libvirt"
      "/var/lib/waydroid"
      "/var/lib/tailscale"
      "/var/lib/upower"

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
        ".config/AusweisApp"
        ".config/discord"
        ".config/Element"
        ".config/feishin"
        ".config/ghb" # HandBrake GUI settings
        ".config/heroic"
        ".config/JetBrains"
        ".config/kdeconnect" # KDEconnect, contains keys for paired phone
        ".config/lutris"
        ".config/ludusavi"
        #".config/microsoft-edge"
        ".config/obs-studio"
        ".config/obsidian"
        ".config/Podman Desktop"
        ".config/Signal"
        ".config/syncthing" # Syncthing settings, e.g. telemetry and web interface
        ".local/share/.shatteredpixel" # Data of Shattered Pixel Dungeon roguelike
        ".local/share/Anki2"
        ".local/share/applications"
        ".local/share/atuin" # Atuin shell history database, host_id and sync keys
        ".local/share/Dungeondraft" # Only config and thumbnail cache
        ".local/share/Wonderdraft" # Only config and thumbnail cache
        ".local/share/flatpak"
        ".local/share/FoundryVTT" # Only user data of Foundry VTT desktop version
        ".local/share/chat.fluffy.fluffychat"
        ".local/share/home-manager"
        ".local/share/JetBrains"
        ".local/share/kwalletd" # KWallet database, contains e.g. WiFi passwords
        ".local/share/kscreen" # KDE Plasma Display/Monitor configuration
        ".local/share/lutris"
        ".local/share/mime"
        ".local/share/nvim" # File Frecency
        ".local/share/containers/podman-desktop"
        ".local/share/PrismLauncher"
        ".local/share/Steam"
        ".local/share/TelegramDesktop"
        ".local/share/zoxide" # Zoxide cd history
        ".ollama"
        ".syncthing-folders" # Default folder for new synced folders
        ".gnupg"
        ".java/.userPrefs/jetbrains"
        ".jdks" # JDKs downloaded by IntellIJ IDEA
        ".m2" # Local Maven Repo
        ".mozilla/firefox"
        ".floorp"
        ".renpy"
        ".ssh"
        ".steam"
        ".thunderbird" # Thunderbird profiles, not config
        ".wine"
        ".zotero"
        "Desktop"
        "Downloads"
        "Games"
      ];
      files = [
        ".config/gh/hosts.yml"
        ".config/kwinoutputconfig.json"
        ".config/powerdevilrc"
        ".config/powermanagementprofilesrc"
        ".config/nix/nix.conf"
      ];
    };
  };

  # Persistent roaming data, e.g. Syncthing folders
  fileSystems."/persist/roaming".neededForBoot = true;
  environment.persistence."/persist/roaming" = {
    hideMounts = true;
    users.${username} = {
      directories = [
        # Syncthing folders
        ".ludusavi-backups"
        "FoundryVTT"
        "Documents"
        "Music"
        "Pictures"
        "Szechuan Sauce"
        "Videos"

        # Non-syncthing but synchronized
        "git"
        "Obsidian Vault"
        "Zotero"
      ];
    };
  };
}
