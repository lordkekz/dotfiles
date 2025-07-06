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
  ];

  # Enable graphical KDE Partition Manager
  programs.partition-manager.enable = true;

  # Enable Steam
  programs.steam.enable = true;

  # Enable ratbagd to configure peripherals with piper
  services.ratbagd.enable = true;

  # Enable ollama service
  services.ollama = {
    enable = true;
    acceleration = "rocm";
  };
}
