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
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    hardwareProfiles.common
  ];

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostId = "f5bf3143";
  systemd.network.enable = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Type = "ether";
    networkConfig = {
      IPv6AcceptRA = true;
      DHCP = "yes";
    };
  };

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "eth0";
    internalInterfaces = ["microvm-robot4care"];
  };
}
