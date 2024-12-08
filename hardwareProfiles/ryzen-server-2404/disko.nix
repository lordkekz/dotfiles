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
  pool-name = "ares";
  root-subvol = "root";
  blank-snapshot = "${pool-name}/${root-subvol}@blank";
in {
  imports = [inputs.disko.nixosModules.disko];

  # Rollback subvolume "root" right after device nodes are initialized
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r ${blank-snapshot}
  '';

  disko.devices = {
    disk = {
      main = {
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
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          ${root-subvol} = {
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
