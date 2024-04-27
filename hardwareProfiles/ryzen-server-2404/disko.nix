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
  pool-name = "venus";
  blank-snapshot = "${pool-name}@blank";
in {
  imports = [inputs.disko.nixosModules.disko];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S21JNXAGA47804H";
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
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/";
        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^${blank-snapshot}$' || zfs snapshot ${blank-snapshot}";
        preMountHook = "zfs rollback -r ${blank-snapshot}";

        datasets = {
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };
          persist = {
            type = "zfs_fs";
            mountpoint = "/persist";
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
            options."com.sun:auto-snapshot" = "true";
          };
          persist-longhorn-test_cluster = {
            type = "zfs_volume";
            size = "100G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/persist/longhorn/test_cluster";
            };
          };
          persist-longhorn-prod_cluster = {
            type = "zfs_volume";
            size = "100G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/persist/longhorn/prod_cluster";
            };
          };
        };
      };
    };
  };
}
