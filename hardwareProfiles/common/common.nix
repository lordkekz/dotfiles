{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}: let
  hasFS = fsType:
    with lib;
      pipe config.fileSystems [
        attrValues
        (catAttrs "fsType")
        (any (x: x == fsType))
      ];
  hasZFS = hasFS "zfs";
  hasBTRFS = hasFS "btrfs";
in {
  services.zfs = {
    trim = {
      enable = lib.mkDefault hasZFS;
      interval = "weekly";
    };
    autoScrub = {
      enable = lib.mkDefault hasZFS;
      interval = "weekly";
    };
  };
  services.btrfs.autoScrub = {
    enable = lib.mkDefault hasBTRFS;
    interval = "weekly";
  };
}
