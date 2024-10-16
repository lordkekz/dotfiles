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
    externalInterface = "eth0";
    internalInterfaces = ["microvm-robot4care"];
  };
}
