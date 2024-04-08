{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}: {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/375397e8-9d5c-44ac-9a33-50b13d897faf";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1687-3703";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/d5c45e29-0278-4f03-920e-76f682c4341c";}
  ];
}
