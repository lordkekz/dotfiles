{
  inputs,
  outputs,
  hardwareProfiles,
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}: let
  pool-name = "artemis";
  root-dataset = "root";
  blank-snapshot = "${pool-name}/${root-dataset}@blank";
in {
  imports = [inputs.disko.nixosModules.disko];

  # Rollback root dataset *before it gets mounted*
  # If you rollback after persist gets mounted inside root,
  # the rollback will also apply to persist
  boot.initrd.systemd.services.rollback = {
    description = "Rollback ZFS datasets to a pristine state";
    serviceConfig.Type = "oneshot";
    unitConfig.DefaultDependencies = "no";
    wantedBy = [
      "initrd.target"
    ];
    after = [
      "zfs-import-zroot.service"
    ];
    before = [
      "sysroot.mount"
    ];
    path = with pkgs; [
      zfs
    ];
    script = ''
      set -ex
      echo "$ zpool list"
      zpool list
      echo "$ zfs list"
      zfs list
      echo "$ zfs rollback -r ${blank-snapshot}"
      zfs rollback -r ${blank-snapshot} && echo "rollback complete"
    '';
  };

  disko.devices = {
    disk = {
      "${pool-name}1" = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Lexar_SSD_NQ790_4TB_PJ6841R000312P220Q";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = pool-name;
              };
            };
          };
        };
      };
    };
    zpool = {
      ${pool-name} = {
        type = "zpool";
        mode = "";
        rootFsOptions = {
          canmount = "off";
        };

        datasets = {
          ${root-dataset} = {
            type = "zfs_fs";
            mountpoint = "/";
            postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^${blank-snapshot}$' || zfs snapshot ${blank-snapshot}";
            options."com.sun:auto-snapshot" = "false";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };
          persist-ephemeral = {
            type = "zfs_fs";
            mountpoint = "/persist/ephemeral";
            options."com.sun:auto-snapshot" = "false";
          };
          persist-local = {
            type = "zfs_fs";
            mountpoint = "/persist/local";
            options."com.sun:auto-snapshot" = "false";
          };
        };
      };
    };
  };
}
