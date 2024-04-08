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
  imports = [
    hardwareProfiles.physical

    # Get the defaults from nixos-hardware
    inputs.hardware.nixosModules.framework-12th-gen-intel

    # Default imports
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # See: https://wiki.archlinux.org/title/Framework_Laptop_13#Lowering_fan_noise
  services.thermald.enable = true;

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "uas" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
