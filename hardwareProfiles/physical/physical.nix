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

  # Bootloader.
  boot.loader = {
    # Use systemd-boot
    systemd-boot = {
      enable = true;
      # Maximum number of old NixOS generations to show in bootloader
      configurationLimit = 40;
      # Add an entry for Memtest86+ (the open source one)
      memtest86.enable = true;
      # Add an entry for a UEFI shell
      edk2-uefi-shell.enable = true;
    };
    efi.canTouchEfiVariables = true;

    # Default entry is booted after timeout seconds
    timeout = 1;
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  # Only physical devices need firmware updates
  services.fwupd.enable = true;
}
