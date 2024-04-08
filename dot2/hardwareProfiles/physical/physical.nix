{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    # Get the defaults from nixos-hardware
    inputs.hardware.nixosModules.framework-12th-gen-intel

    # Default imports
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Bootloader.
  boot.loader = {
    # Use systemd-boot
    systemd-boot = {
      enable = true;
      # Maximum number of old NixOS generations to show in bootloader
      configurationLimit = 40;
      # Add an entry for Memtest86+ (the open source one)
      memtest86.enable = true;
    };
    efi.canTouchEfiVariables = true;

    # Default entry is booted after timeout seconds
    timeout = 1;
  };

  # See: https://wiki.archlinux.org/title/Framework_Laptop_13#Lowering_fan_noise
  services.thermald.enable = true;

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "uas" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
