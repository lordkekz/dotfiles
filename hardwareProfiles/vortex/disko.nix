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

  boot.tmp.useTmpfs = lib.mkForce false;

  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
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
          nixos = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "/persist/tmp" = {
                  mountpoint = "/tmp";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/persist/ephemeral" = {
                  mountpoint = "/persist/ephemeral";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/persist/local" = {
                  mountpoint = "/persist/local";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/persist/roaming" = {
                  mountpoint = "/persist/roaming";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/swap" = {
                  mountpoint = "/.swapvol";
                  swap.swapfile.size = "8G";
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
