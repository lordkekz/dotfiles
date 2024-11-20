{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: {
  microvm.vms.radicale.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {vmName = "radicale";})];

    systemd.network.networks."20-lan" = {
      matchConfig.Type = "ether";
      networkConfig = {
        Address = "10.0.0.12/24";
        Gateway = "10.0.0.1";
      };
    };

    microvm.shares = [
      {
        mountPoint = "/persist";
        source = "/persist/local/microvm-radicale";
        tag = "microvm-radicale-persist";
        securityModel = "mapped";
      }
    ];

    networking.firewall.allowedTCPPorts = [5232];

    services.radicale = {
      enable = true;
      settings = {
        server.hosts = ["0.0.0.0:5232"];
        auth = {
          type = "htpasswd";
          htpasswd_filename = pkgs.writeText personal-data.data.home.radicale.usersFile;
          htpasswd_encryption = "autodetect";
        };
        storage = {
          filesystem_folder = "/persist/radicale-collections";
        };
      };
    };
  };
}
