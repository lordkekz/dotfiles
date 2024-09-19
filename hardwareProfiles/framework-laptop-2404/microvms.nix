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
  imports = [inputs.microvm.nixosModules.host];

  microvm.vms = let
    fun = id: config: {
      #specialArgs = {};

      config = {
        imports = [config];

        microvm.mem = lib.mkForce 8192; # MB
        microvm.vcpu = 4; # 4 virtual CPU cores

        # It is highly recommended to share the host's nix-store
        # with the VMs to prevent building huge images.
        microvm.shares = [
          {
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            tag = "ro-store";
            proto = "virtiofs";
          }
        ];

        microvm.interfaces = [
          {
            type = "tap";
            id = "vm-test${id}";
            mac = "02:00:00:00:00:${id}";
          }
        ];

        networking.firewall.enable = false;
        networking.networkmanager.enable = false;
        networking.useDHCP = false;
        systemd.network = {
          enable = true;
          networks."10-lan" = {
            matchConfig.Name = "enp0s3";
            networkConfig = {
              Bridge = "vmbr0";
            };
          };

          netdevs."vmbr0" = {
            netdevConfig = {
              Name = "vmbr0";
              Kind = "bridge";
            };
          };

          networks."10-lan-bridge" = {
            matchConfig.Name = "vmbr0";
            networkConfig = {
              Address = ["192.168.2.${id}/24"];
              Gateway = "192.168.2.1";
              DNS = ["192.168.2.1"];
              DHCP = "no";
            };
            linkConfig.RequiredForOnline = "routable";
          };
        };

        services.openssh = {
          enable = true;
          banner = ''
            anyway, you should probably try to remember the password now :D
          '';
        };
        users.users.worm = {
          isNormalUser = true;
          password = "hihiaha";
          extraGroups = ["wheel"];
        };
        users.groups.users = {};

        nix.settings.experimental-features = ["nix-command" "flakes"];
      };
    };
  in {
    my-node-1 = fun "41" {
      services.k3s = {
        enable = true;
        extraFlags = "--cluster-cidr 10.24.0.0/16";
        role = "server";
        token = "randomizedsecret";
        clusterInit = true;
      };
    };
    my-node-2 = fun "42" {
      config.services.k3s = {
        enable = true;
        extraFlags = "--cluster-cidr 10.24.0.0/16";
        role = "server"; # Or "agent" for worker only nodes
        token = "randomizedsecret";
        serverAddr = "https://192.168.2.41:6443";
      };
    };
    my-node-3 = fun "43" {
      config.services.k3s = {
        enable = true;
        extraFlags = "--cluster-cidr 10.24.0.0/16";
        role = "server"; # Or "agent" for worker only nodes
        token = "randomizedsecret";
        serverAddr = "https://192.168.2.41:6443";
      };
    };
  };

  ## NETWORKING
  networking.networkmanager.enable = lib.mkForce false;
  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = ["enp0s13f0u2" "enp0s13f0u3" "vm-*"];
      networkConfig = {
        Bridge = "br0";
      };
    };

    netdevs."br0" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
      };
    };

    networks."10-lan-bridge" = {
      matchConfig.Name = "br0";
      networkConfig = {
        Address = ["192.168.2.118/24"];
        Gateway = "192.168.2.1";
        DNS = ["192.168.2.1"];
        DHCP = "no";
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
