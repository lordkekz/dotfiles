# Misc programs to enable on desktops.
{
  inputs,
  outputs,
  nixosProfiles,
  lib,
  config,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  ...
}: {
  environment.systemPackages = [
    # KDE Info Center dependencies, but useful on most desktops.
    pkgs.wayland-utils
    pkgs.clinfo
    pkgs.glxinfo
    pkgs.vulkan-tools-lunarg
    pkgs.pciutils # provides lspci
    pkgs.usbutils # provides lsusb
    pkgs.fwupd
  ];

  # Enable graphical KDE Partition Manager
  programs.partition-manager.enable = true;

  # Enable Steam
  programs.steam.enable = true;

  # Enable ratbagd to configure peripherals with piper
  services.ratbagd.enable = true;

  # Enable Waydroid to run Android apps
  virtualisation.waydroid.enable = true;

  # Enable virt-manager for QUEMU/KVM based VMs
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
