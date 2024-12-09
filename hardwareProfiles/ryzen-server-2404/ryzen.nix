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

    # Default imports
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Required for secrets
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQr2o65WM22z2c3nyY9DYTxSlfO5UH6jUgc33TlDBRR root@nasman2404";
  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  services.openssh.ports = [4286];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "uas" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
  boot.supportedFilesystems = ["zfs"];

  # This should enable the `amd_pstate` cpuidle driver, by default it ended up with `none`
  boot.kernelParams = ["amd_pstate=active"];

  networking.hostId = "2e2e01d4";
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    netdevs."10-microvm".netdevConfig = {
      Kind = "bridge";
      Name = "microvm";
    };
    networks."11-microvm" = {
      matchConfig.Name = "vm-*";
      # Attach to the bridge that was configured above
      networkConfig.Bridge = "microvm";
    };
    networks."10-microvm" = {
      matchConfig.Name = "microvm";
      addresses = [{addressConfig.Address = "10.0.0.1/24";}];
    };
  };

  # Provide microvms with internet using NAT
  networking.nat = {
    enable = true;
    externalInterface = "enp3s0";
    internalInterfaces = ["microvm"];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
