{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: let
  domain = "git.hepr.me";
in {
  services.caddy.virtualHosts.${domain}.extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    request_body {
      max_size 1GB
    }
    reverse_proxy http://10.0.0.13:8000
  '';

  networking.firewall.allowedTCPPorts = [22];
  networking.nat.forwardPorts = [
    {
      proto = "tcp";
      sourcePort = 22;
      destination = "10.0.0.13:2222";
    }
  ];

  microvm.vms.forgejo.config = {config, ...}: {
    imports = [
      (import ./__microvmBaseConfig.nix {
        vmName = "forgejo";
        vmId = "13";
      })
    ];

    microvm.shares = [
      {
        mountPoint = "/persist";
        source = "/persist/local/microvm-forgejo";
        tag = "microvm-forgejo-persist";
        securityModel = "mapped";
      }
    ];

    networking.firewall.allowedTCPPorts = [22 80 2222];

    services.forgejo = {
      enable = true;

      #user = "root";
      #group = "root";

      stateDir = "/persist";

      # Enable support for Git Large File Storage
      lfs.enable = true;
      settings = {
        DEFAULT = {
          RUN_MODE = "dev";
        };
        server = {
          DOMAIN = domain;
          # You need to specify this to remove the port from URLs in the web UI.
          ROOT_URL = "https://${domain}/";
          PROTOCOL = "http";
          HTTP_PORT = 8000;
          HTTP_ADDR = "0.0.0.0";
          SSH_PORT = 2222;
          START_SSH_SERVER = true;
        };
        # You can temporarily allow registration to create an admin user.
        service.DISABLE_REGISTRATION = true;
        # FIXME maybe activate this, not sure if it works with reverse proxy setup
        session.COOKIE_SECURE = false;
      };
    };
  };
}
