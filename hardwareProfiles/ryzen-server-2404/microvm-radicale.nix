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
    imports = [
      (import ./__microvmBaseConfig.nix {
        vmName = "radicale";
        vmId = "12";
      })
    ];

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
          htpasswd_filename = "${pkgs.writeText "radicale-users" personal-data.data.home.radicale.usersFile}";
          htpasswd_encryption = "autodetect";
        };
        storage = {
          filesystem_folder = "/persist/radicale-collections";
        };
      };
    };
  };
}
