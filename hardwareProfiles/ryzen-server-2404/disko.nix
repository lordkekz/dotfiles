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
  options = {
    "xattr" = "sa";
    "acltype" = "posixacl";
    "com.sun:auto-snapshot" = "false";
  };

  # Orion HDDs are commented out because they are not needed for disko-install
  orion-hdd-template = {
    type = "disk";
    content.type = "gpt";
    content.partitions.zfs = {
      size = "100%";
      content.type = "zfs";
      content.pool = "orion";
    };
  };
in {
  imports = [inputs.disko.nixosModules.disko];

  # Rollback root dataset *before it gets mounted*
  # If you rollback after persist gets mounted inside root,
  # the rollback will also apply to persist
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.services.rollback = {
    description = "Rollback ZFS datasets to a pristine state";
    serviceConfig.Type = "oneshot";
    unitConfig.DefaultDependencies = "no";
    wantedBy = [
      "initrd.target"
    ];
    after = [
      "zfs-import-${pool-name}.service"
    ];
    before = [
      "sysroot.mount"
    ];
    path = with pkgs; [
      zfs
    ];
    script = ''
      set -ex
      zpool list
      zfs list
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
      # Orion HDDs are commented out because they are not needed for disko-install
      #"orion1" = orion-hdd-template // {device = "/dev/disk/by-id/ata-TOSHIBA_MG10ACA20TE_Z2F0A1HGF4MJ";};
      #"orion2" = orion-hdd-template // {device = "/dev/disk/by-id/ata-TOSHIBA_MG10ACA20TE_Z2F0A1GZF4MJ";};
      #"orion3" = orion-hdd-template // {device = "/dev/disk/by-id/ata-TOSHIBA_MG10ACA20TE_Z2F0A1HDF4MJ";};
    };
    zpool = {
      ${pool-name} = {
        type = "zpool";
        mode = "";
        rootFsOptions =
          options
          // {
            canmount = "off";
          };

        datasets = {
          ${root-dataset} = {
            type = "zfs_fs";
            mountpoint = "/";
            postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^${blank-snapshot}$' || zfs snapshot ${blank-snapshot}";
            inherit options;
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            inherit options;
          };
          persist-ephemeral = {
            type = "zfs_fs";
            mountpoint = "/persist/ephemeral";
            inherit options;
          };
          persist-local = {
            type = "zfs_fs";
            mountpoint = "/persist/local";
            inherit options;
          };
          # The zvol definitions here are untested!
          # I couldn't be bothered to reinstall the
          # server to test it.
          microvm-syncit = {
            type = "zfs_volume";
            size = "600G";
            content = {
              type = "filesystem";
              format = "ext4";
            };
          };
          microvm-syncit-cc = {
            type = "zfs_volume";
            size = "300G";
            content = {
              type = "btrfs";
            };
          };
          microvm-syncit-hs = {
            type = "zfs_volume";
            size = "300G";
            content = {
              type = "btrfs";
            };
          };
          microvm-forgejo = {
            type = "zfs_volume";
            size = "100G";
            content = {
              type = "filesystem";
              format = "ext4";
            };
          };
          microvm-radicale = {
            type = "zfs_volume";
            size = "10G";
            content = {
              type = "filesystem";
              format = "ext4";
            };
          };
        };
      };

      orion = {
        type = "zpool";
        datasets = {
          # Dataset containing backups from artemis pool
          backups = {
            type = "zfs_fs";
            mountpoint = "/orion/backups";
            inherit options;
          };
        };
      };
    };
  };
}
