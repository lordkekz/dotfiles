# Basic user account config.
{
  inputs,
  outputs,
  nixosProfiles,
  personal-data,
  lib,
  config,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  ...
}: let
  inherit (personal-data.data.lab) username fullName hashedPassword;
in {
  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    description = fullName;
    inherit hashedPassword;
    extraGroups = ["wheel" "libvirtd" "lxd" "incus-admin"];
  };
}
