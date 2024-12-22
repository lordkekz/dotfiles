{
  inputs,
  lib,
  config,
  pkgs,
  workloadProfiles,
  ...
}: {
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
  systemd.services.microvm-zvol-chown = let
    inherit (lib) attrNames length concatMapStrings;
    vmNames = attrNames config.microvm.vms;
    vmCount = length vmNames;
    vmUnits = map (vm: "microvm@${vm}.service") vmNames;
  in {
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
}
