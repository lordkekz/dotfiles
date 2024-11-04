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
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    hardwareProfiles.common
  ];

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostId = "f5bf3143";

  # do not use DHCP, as webtropia provisions IPs using cloud-init
  networking.useDHCP = lib.mkForce false;
  services.cloud-init = {
    enable = true;
    network.enable = true;
  };

  systemd.network.enable = true;
  systemd.network.networks = {
    "05-lan-ipv4" = {
      matchConfig.Type = "ether";
      #gateway = [ "81.30.159.105" ];
      routes = [
        {
          routeConfig = {
            Gateway = "81.30.159.105";
            GatewayOnLink = "yes";
          };
        }
      ];
      #networkConfig = {
      #  IPv6AcceptRA = true;
      #  DHCP = "no";
      #};
    };
    #"10-lan-ipv6" = {
    #  matchConfig.Type = "ether";
    #  gateway = [ "" ];
    #  networkConfig = {
    #    IPv6AcceptRA = true;
    #    DHCP = "no";
    #  };
    #};
  };

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "eth0";
    internalInterfaces = ["microvm-robot4care"];
  };
}
