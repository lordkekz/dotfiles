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
  inherit (personal-data.data.lab) username fullName hashedPassword publicKeys;
in {
  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    description = fullName;
    inherit hashedPassword;
    openssh.authorizedKeys.keys = publicKeys;
    extraGroups = ["wheel" "libvirtd" "lxd" "incus-admin"];
  };
}
