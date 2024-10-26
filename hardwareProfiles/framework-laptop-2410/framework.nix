{
  inputs,
  outputs,
  hardwareProfiles,
  lib,
  config,
  pkgs,
  modulesPath,
  system,
  ...
}: {
  imports = [
    hardwareProfiles.physical

    # Get the defaults from nixos-hardware
    inputs.hardware.nixosModules.framework-16-7040-amd

    # Default imports
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Enable bluetooth (why wouldn't they enable it in nixos-hardware?!?)
  hardware.bluetooth.enable = true;

  # Enable boltctl (why wouldn't they enable it in nixos-hardware?!?)
  services.hardware.bolt.enable = true;

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "uas" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "50%";
  };

  # Add an entry for Windows 11's Boot Manager.
  # Somehow it got installed into NixOS's ESP.
  # But that turns out to be required, see:
  # https://wiki.archlinux.org/title/Systemd-boot#Boot_from_another_disk
  boot.loader.systemd-boot.extraEntries."Win11.conf" = ''
    title Win11
    efi /EFI/Microsoft/Boot/bootmgfw.efi
    sort-key _Win11
  '';

  # Enable ZFS support, mainly for building images of ZFS-based servers
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "1be6942e";

  # Required for secrets
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJod+kYj/kZCsudSwK1Q2aEZGukQUixQ4KFVblD8zuQ hpreiser@keksjumbo2410";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
