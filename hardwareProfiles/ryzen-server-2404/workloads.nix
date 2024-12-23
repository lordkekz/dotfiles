{
  inputs,
  lib,
  config,
  pkgs,
  workloadProfiles,
  ...
}: let
  inherit (lib) attrNames length concatMapStrings;
  vmNames = attrNames config.microvm.vms;
  vmCount = length vmNames;
  vmUnits = map (vm: "microvm@${vm}.service") vmNames;
in {
  imports = [
    inputs.microvm.nixosModules.host
    workloadProfiles.microvm-syncit-cc
    workloadProfiles.microvm-syncit-ho
    workloadProfiles.microvm-syncit-hs
    workloadProfiles.microvm-radicale
    workloadProfiles.microvm-forgejo
  ];

  # This is probably only needed on first boot, but this
  # ensures that vms can access the volumes in any case
  systemd.services.microvm-zvol-chown = {
    enableStrictShellChecks = true;
    script =
      (concatMapStrings (vmName: ''
          target=/dev/zvol/artemis/microvm-${vmName}
          echo "chowning $target for microvm:kvm"
          chown microvm:kvm -c  "$target" # This chowns /dev/zdN
          chown microvm:kvm -ch "$target" # This chowns the symlink in /dev/zvol/...
        '')
        vmNames)
      + ''
        echo "I ensured ownership for ${toString vmCount} zvols!"
      '';
    # oneshot services count as "activating" until script exits, afterwards "inactive (dead)".
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = "no";
    wantedBy = ["multi-user.target"] ++ vmUnits;
    before = ["multi-user.target"] ++ vmUnits;
    wants = ["zfs-import.target"];
    after = ["zfs-import.target"];
  };

  # Use zfs snapshots and zfs send/recv for backups
  # Inspired by: https://xai.sh/2018/08/27/zfs-incremental-backups.html
  systemd.services.microvm-zvol-backup = {
    enableStrictShellChecks = true;
    script =
      ''
        ${builtins.readFile ./backup-lib.bash}

        echo "####################################"
        echo "Creating snapshot for zpool artemis!"
        new_snap_name=$(date +%Y-%m-%d-%H%M-autobackup)
        create_recursive_snapshot artemis "$new_snap_name"
        destroy_unwanted_snapshot artemis/root "$new_snap_name"

        echo "################################################"
        echo "Making backup of microvm volumes to zpool orion!"
      ''
      + (concatMapStrings (vmName: ''
          backup_volume artemis orion/backups ${vmName}
        '')
        vmNames);
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    startAt = "5:12"; # Runs daily in the early morning when there is no traffic
    wants = ["zfs-import.target"];
    after = ["zfs-import.target"];
  };
}
