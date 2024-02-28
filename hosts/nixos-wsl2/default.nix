# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  username = "hpreiser";
in {
  # You can import other NixOS modules here
  imports = [
    # You can also split up your configuration and import pieces of it here:
    ../common/base-config.nix

    inputs.NixOS-WSL.nixosModules.wsl
  ];

  # Let NixOS-WSL handle compatibility options
  wsl.enable = true;
  wsl.defaultUser = username;

  # Networking basically just works
  networking.hostName = "nixos-wsl2";

  # Basic user account config.
  users.users.${username} = {
    isNormalUser = true;
    description = "Heinrich Preiser";
    extraGroups = ["networkmanager" "wheel" "docker" "libvirtd" "lxd" "incus-admin"];
  };

  # Enable Waydroid to run Android apps on Linux.
  virtualisation.waydroid.enable = true;

  # Enable LXC/LXD containers
  virtualisation.lxd.enable = true;

  # Enable Incus LXC containers
  virtualisation.incus.enable = true;
}
