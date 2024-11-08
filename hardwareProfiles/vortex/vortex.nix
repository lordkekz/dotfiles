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

  nix.settings.trusted-users = ["hpreiser"];

  # Required for secrets
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAaGoNO2VY46hVJ4uhlMg+/B38aOCeubw/Zc15X2ExX hpreiser@vortex";

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
      matchConfig.Name = "enp0s18";
      routes = [
        {
          routeConfig = {
            Gateway = "81.30.159.105";
            GatewayOnLink = "yes";
          };
        }
      ];
      networkConfig = {
        IPv6AcceptRA = false;
        DHCP = "no";
        Address = "85.114.138.64";
        DNS = "8.8.8.8";
      };
    };
    "05-lan-ipv6" = {
      matchConfig.Name = "enp0s19";
      routes = [
        {
          routeConfig = {
            Gateway = "2001:4ba0:cafe:babe::a105";
            GatewayOnLink = "yes";
          };
        }
      ];
      networkConfig = {
        IPv6AcceptRA = false;
        DHCP = "no";
        Address = "2001:4ba0:cafe:1132::1/128";
        DNS = "2001:4860:4860::8888";
      };
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
    enable = false;
    enableIPv6 = true;
    externalInterface = "eth0";
    internalInterfaces = ["microvm-robot4care"];
  };
}
