# This config will be used for headless, non-graphical devices such as servers.
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
  inherit (personal-data.data.home) username fullName;
in {
  imports = [
    nixosProfiles.common
    inputs.NixOS-WSL.nixosModules.wsl
  ];

  # Let NixOS-WSL handle compatibility options
  wsl.enable = true;
  wsl.defaultUser = username;

  # Basic user account config.
  users.users.${username} = {
    isNormalUser = true;
    description = fullName;
    extraGroups = ["networkmanager" "wheel" "libvirtd" "lxd" "incus-admin"];
  };
}
