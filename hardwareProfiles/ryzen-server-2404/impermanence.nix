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
  inherit (personal-data.data.lab) username;
in {
  imports = [inputs.impermanence.nixosModules.impermanence];
  fileSystems."/".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;

  # Persistent but ephemeral data, e.g. logs, VMs and containers, caches
  fileSystems."/persist/ephemeral".neededForBoot = true;
  environment.persistence."/persist/ephemeral" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/systemd/coredump"
      "/var/lib/acme"
      "/var/lib/ai-stuff" # Used by Ollama and Open WebUI
    ];
    files = [
    ];
    users.${username} = {
      directories = [
        ".config/carapace"
        ".config/nushell"

        ".cache/bat"
        ".cache/nix"
        ".cache/tealdeer"
      ];
      files = [
        ".local/share/nix/repl-history"
      ];
    };
  };

  # Persistent local data
  fileSystems."/persist/local".neededForBoot = true;
  environment.persistence."/persist/local" = {
    hideMounts = true;
    directories = [
      "/var/db/sudo/lectured"
      "/var/lib/tailscale"
      "/var/lib/nixos"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];

    users.${username} = {
      directories = [
        ".local/share/atuin" # Atuin shell history database, host_id and sync keys
        ".local/share/home-manager"
        ".local/share/nvim" # File Frecency
        ".local/share/zoxide" # Zoxide cd history
        ".gnupg"
        ".ssh"
        "Downloads"
        "git"
      ];
      files = [
        ".config/nix/nix.conf"
      ];
    };
  };
}
