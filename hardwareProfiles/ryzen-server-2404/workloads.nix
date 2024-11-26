{
  inputs,
  lib,
  config,
  pkgs,
  workloadProfiles,
  ...
}: {
  imports = [
    inputs.microvm.nixosModules.host
    workloadProfiles.microvm-syncit
    workloadProfiles.microvm-radicale
    workloadProfiles.microvm-forgejo
  ];
}
