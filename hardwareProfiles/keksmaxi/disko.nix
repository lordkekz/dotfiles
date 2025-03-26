{
  inputs,
  outputs,
  hardwareProfiles,
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [inputs.disko.nixosModules.disko];

  disko.devices = {
    disk = {
      keksmaxi = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_22260N801336";
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
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted-keksmaxi";
                # LUKS will ask for password during boot
                passwordFile = "/tmp/luks-password";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    persist-ephemeral = {
                      mountpoint = "/persist/ephemeral";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    persist-local = {
                      mountpoint = "/persist/local";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    persist-roaming = {
                      mountpoint = "/persist/roaming";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    nix = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    swap = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "32G";
                    };
                  };
                };
              };
            };
          };
        };
      };
      rustygames = {
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_DT01ACA200_Y5GHG99GS";
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted-rustygames";
                # LUKS will ask for password during boot
                passwordFile = "/tmp/luks-password";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    rustygames = {
                      mountpoint = "/persist/rustygames";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=50%"
        "defaults"
        "mode=755"
      ];
    };
  };
}
