{
  inputs,
  outputs,
  hardwareProfiles,
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}: let
  lan-interface = "enp*s0";
  main-bridge = "br0";
in {
  imports = [
    hardwareProfiles.physical

    # Default imports
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "uas" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
  boot.supportedFilesystems = ["zfs"];

  networking.hostId = "2e2e01d4";
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;

    # Primary bridge interface to be attach MicroVMs to LAN
    netdevs.${main-bridge}.netdevConfig = {
      Kind = "bridge";
      Name = main-bridge;
    };

    # Connect the bridge ports to the bridge
    networks."10-lan" = {
      matchConfig.Name = [lan-interface "vm-*"];
      networkConfig.Bridge = main-bridge;
      linkConfig.RequiredForOnline = "enslaved";
    };

    # Configure the bridge for its desired function
    networks."10-lan-bridge" = {
      matchConfig.Name = main-bridge;
      bridgeConfig = {};
      # Disable address autoconfig when no IP configuration is required
      #networkConfig.LinkLocalAddressing = "no";
      networkConfig = {
        # start a DHCP Client for IPv4 Addressing/Routing
        DHCP = "ipv4";
        # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
        IPv6AcceptRA = true;
      };
      linkConfig = {
        # or "routable" with IP addresses configured
        RequiredForOnline = "carrier";
      };
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
