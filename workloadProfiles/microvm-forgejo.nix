{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: let
  vmName = "forgejo";
  vmId = "13";
  domain = "git.hepr.me";
  internalIP = "10.0.0.13";
in {
  services.caddy.virtualHosts.${domain}.extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    request_body {
      max_size 1GB
    }
    reverse_proxy http://${internalIP}:8000
  '';

  networking.firewall.allowedTCPPorts = [22];
  networking.nat.forwardPorts = [
    {
      proto = "tcp";
      sourcePort = 22;
      destination = "${internalIP}:2222";
    }
  ];

  systemd.services."microvm@${vmName}".preStart = "+mkdir -p /persist/local/vm-${vmName}";
  microvm.vms.forgejo.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {inherit vmName vmId;})];

    networking.firewall.allowedTCPPorts = [22 8000 2222];

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
          # HTTP settings
          DOMAIN = domain;
          ROOT_URL = "https://${domain}/"; # Displayed in UI
          PROTOCOL = "http";
          HTTP_PORT = 8000;
          HTTP_ADDR = internalIP;

          # SSH settings
          START_SSH_SERVER = true;
          BUILTIN_SSH_SERVER_USER = "git";
          SSH_PORT = 22; # Displayed in UI
          SSH_LISTEN_PORT = 2222;
          SSH_LISTEN_HOST = internalIP;
        };
        # You can temporarily allow registration to create an admin user.
        service.DISABLE_REGISTRATION = true;
        # FIXME maybe activate this, not sure if it works with reverse proxy setup
        session.COOKIE_SECURE = false;
        # Workaround for crash on 9p mount, see:
        # https://github.com/go-gitea/gitea/issues/8566#issuecomment-745723498
        # TODO maybe use `bleve` but move the index to a non-persistent directory
        # Especially because `db` doesn't support code indexing:
        # https://github.com/go-gitea/gitea/issues/8566#issuecomment-753418689
        indexer.ISSUE_INDEXER_TYPE = "db";
      };
    };

    # Make sure the forgejo user can access the persistent data
    # This is probably only needed on first boot to set the xargs due to 9p mount mode "mapped"
    # Better to chown them at each start of the VM so the files can be touched from the host without worry
    systemd.services.forgejo.preStart = "+chown -R forgejo:forgejo /persist";
  };
}
