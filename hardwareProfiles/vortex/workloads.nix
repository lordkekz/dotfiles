{
  inputs,
  lib,
  config,
  pkgs,
  workloadProfiles,
  ...
}: {
  imports = [
    workloadProfiles.public-websites
  ];
}
