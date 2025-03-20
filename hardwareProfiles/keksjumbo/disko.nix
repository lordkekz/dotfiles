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
      keksjumbo = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN770M_2TB_23492Q802076";
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
                name = "crypted-keksjumbo";
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
                      swap.swapfile.size = "4G";
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
