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
  imports = [hardwareProfiles.common];

  networking.hostId = "f5bf3143";
  networking.useNetworkd = true;

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    # Change this to the interface with upstream Internet access
    externalInterface = "eth0";
    internalInterfaces = ["microvm"];
  };
}
