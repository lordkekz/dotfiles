{
  inputs,
  outputs,
  hardwareProfiles,
  lib,
  config,
  pkgs,
  pkgs-unstable,
  modulesPath,
  system,
  ...
}: {
  imports = [
    hardwareProfiles.physical

    # Default imports
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Enable bluetooth (why wouldn't they enable it in nixos-hardware?!?)
  hardware.bluetooth.enable = true;

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "uas" "usb_storage" "usbhid" "sd_mod" "wl"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = with config.boot.kernelPackages; [broadcom_sta];
  boot.blacklistedKernelModules = ["bcma" "b43"];

  boot.kernelPackages = pkgs.linuxPackages;
  # boot.kernelPackages = pkgs-unstable.linuxPackages;

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "50%";
  };

  # Enable ZFS support, mainly for building images of ZFS-based servers
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "a2128b4d";

  # Required for secrets
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOx5U8xcaI2oWKGA1FW+w9NHOOJKc8Xa0yD40Cl2D9qt hpreiser@keksmaxi";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
