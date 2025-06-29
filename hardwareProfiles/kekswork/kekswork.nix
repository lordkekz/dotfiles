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
    inputs.hardware.nixosModules.framework-12th-gen-intel

    "${inputs.self.outPath}/stylix-light.nix"

    # Default imports
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Enable bluetooth (why wouldn't they enable it in nixos-hardware?!?)
  hardware.bluetooth.enable = true;

  # Enable boltctl (why wouldn't they enable it in nixos-hardware?!?)
  services.hardware.bolt.enable = true;

  # See: https://wiki.archlinux.org/title/Framework_Laptop_13#Lowering_fan_noise
  services.thermald.enable = true;

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "uas" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "50%";
  };

  # Enable ZFS support, mainly for building images of ZFS-based servers
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "bb80a896";

  # Required for secrets
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO47IEdA84D66Pu3af+lv9Xfzwk7e9xNlgNaGAQ3muJo hpreiser@kekswork2404";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Use old fw-ectool because newer versions seem broken on 12th gen intel
  environment.systemPackages = let
    oldpkgs = import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/f6348ff1c9260b94ff9e25a2b04020d12bc820a8.tar.gz";
      sha256 = "sha256:1i84qlfj4nf27zbbjngr6l8xb986k1ggy15c697601sp7r3x1sh5";
    }) {inherit system;};
    hiPrioEctool = lib.hiPrio oldpkgs.fw-ectool;
  in [hiPrioEctool];
}
