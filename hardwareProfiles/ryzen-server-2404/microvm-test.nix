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
  inherit (inputs) microvm;
in {
  imports = [microvm.nixosModules.host];

  microvm.vms = {
    my-microvm = {
      # The package set to use for the microvm. This also determines the microvm's architecture.
      # (Optional) A set of special arguments to be passed to the MicroVM's NixOS modules.
      #specialArgs = {};

      # The configuration for the MicroVM.
      # Multiple definitions will be merged as expected.
      config = {config, ...}: {
        # It is highly recommended to share the host's nix-store
        # with the VMs to prevent building huge images.
        microvm.shares = [
          {
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            tag = "ro-store";
            proto = "9p";
            # virtiofs should also be possible but needs extra config for zfs
            # https://astro.github.io/microvm.nix/shares.html
          }
        ];

        microvm.interfaces = [
          {
            type = "tap";
            id = "vm-test1";
            mac = "02:00:00:00:00:01";
          }
        ];

        services.openssh = {
          enable = true;
          banner = ''
            Lorem ipsum dolor sit forget the text but it's okay...
            just testing microvm.nix

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

        systemd.network.enable = true;

        systemd.network.networks."20-lan" = {
          matchConfig.Type = "ether";
          networkConfig = {
            IPv6AcceptRA = true;
            DHCP = "yes";
          };
        };
      };
    };
  };
}
