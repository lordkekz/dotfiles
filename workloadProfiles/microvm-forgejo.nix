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
  user = "forgejo";
  group = "forgejo";
  unitsAfterPersist = ["forgejo-secrets.service" "forgejo.service"];
  persistentSizeInGiB = 100;
  hostConfig = config;
  microvmSecretsDir = "/run/agenix-microvm-forgejo";
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

  microvm.vms.forgejo.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {inherit vmName vmId user group unitsAfterPersist persistentSizeInGiB;})];

    networking.firewall.allowedTCPPorts = [22 8000 2222];

    microvm.shares = [
      {
        mountPoint = microvmSecretsDir;
        source = microvmSecretsDir;
        tag = "microvm-forgejo-secret";
        securityModel = "mapped";
      }
    ];

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

    # See https://wiki.nixos.org/wiki/Forgejo#Ensure_users
    systemd.services.forgejo.preStart = let
      adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
      passwordFile = hostConfig.age.secrets.forgejo-password.path;
      inherit (inputs.personal-data.data.home.git) userName userEmail; # Note, Forgejo doesn't allow creation of an account named "admin"
    in ''
      ${adminCmd} create --admin --email "${userEmail}" --username "${userName}" --password "$(tr -d '\n' < ${passwordFile})" || true
      ## uncomment this line to change an admin user which was already created
      ${adminCmd} change-password --username "${userName}" --password "$(tr -d '\n' < ${passwordFile})" || true
    '';
  };

  age.secrets.forgejo-password = {
    rekeyFile = "${inputs.self.outPath}/secrets/forgejo-password.age";
    path = "${microvmSecretsDir}/forgejo-password";
    symlink = false; # Required since the vm can't see the target if it's a symlink
    owner = "microvm";
    group = "kvm";
  };
}
