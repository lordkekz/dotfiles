{
  inputs,
  lib,
  config,
  pkgs,
  workloadProfiles,
  ...
}: {
  imports = with workloadProfiles; [
    public-websites
    mailserver
  ];
}
