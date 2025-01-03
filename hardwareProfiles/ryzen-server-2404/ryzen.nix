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
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC8hRwBv9JkDKcSaP1bwwz61MLzB5RFt3IkiM+IjP+vR root@nasman2404";
  age.identityPaths = lib.mkForce ["/persist/local/etc/ssh/ssh_host_ed25519_key"];
  services.openssh.ports = [4286];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "uas" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
  boot.supportedFilesystems = ["zfs"];

  # This should enable the `amd_pstate` cpuidle driver, by default it ended up with `none`
  boot.kernelParams = ["amd_pstate=active"];

  # btrfs tools are for some reason not always included if there is no btrfs filesystem in config
  environment.systemPackages = [pkgs.btrfs-progs];

  networking.hostId = "2e2e01d4";
  networking.useNetworkd = true;
  systemd.network = let
    networks = variant: gateway: {
      netdevs."10-microvm-${variant}".netdevConfig = {
        Kind = "bridge";
        Name = "microvm-${variant}";
      };
      networks."11-microvm-${variant}" = {
        matchConfig.Name = "vm-*-${variant}";
        # Attach to the bridge that was configured above
        networkConfig.Bridge = "microvm-${variant}";
      };
      networks."10-microvm-${variant}" = {
        matchConfig.Name = "microvm-${variant}";
        addresses = [{addressConfig.Address = "${gateway}/24";}];
      };
    };
    recursiveUpdateList = lib.foldl lib.recursiveUpdate;
  in
    recursiveUpdateList {enable = true;} [
      # Use for proxy -> backend connections, e.g. Web UI
      (networks "a" "10.0.0.1")
      # Use for direct connections, e.g. Syncthing traffic
      (networks "b" "100.80.64.1")
    ];

  # Provide microvms with internet using NAT
  networking.nftables.enable = true;
  networking.nat = {
    enable = true;
    externalInterface = "enp3s0";
    internalInterfaces = ["microvm-a"];
  };

  # Allow direct communication between Tailscale devices and VMs
  services.tailscale.extraSetFlags = ["--advertise-routes=100.80.64.0/20"];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
