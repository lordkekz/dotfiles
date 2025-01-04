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
  pathsToChown = ["/persist" microvmSecretsDir];
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
  networking.nftables.ruleset = ''
    table ip nat {
      chain PREROUTING {
        type nat hook prerouting priority dstnat; policy accept;
        tcp dport 22 dnat to 10.0.0.${vmId}:2222
      }
    }
  '';

  microvm.vms.${vmName}.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {inherit personal-data vmName vmId user group unitsAfterPersist pathsToChown;})];

    networking.firewall.interfaces = {
      "vm-${vmName}-a".allowedTCPPorts = [22 2222 8000];
      "vm-${vmName}-b".allowedTCPPorts = [];
    };

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
          RUN_MODE = "prod";
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
        session.COOKIE_SECURE = true;
        # Workaround for crash on 9p mount, see:
        # https://github.com/go-gitea/gitea/issues/8566#issuecomment-745723498
        # TODO maybe use `bleve` but move the index to a non-persistent directory
        # Especially because `db` doesn't support code indexing:
        # https://github.com/go-gitea/gitea/issues/8566#issuecomment-753418689
        indexer.ISSUE_INDEXER_TYPE = "db";

        # Email (outgoing)
        # You can send a test email from the web UI at:
        # Profile Picture > Site Administration > Configuration >  Mailer Configuration 
        mailer = {
          ENABLED = true;
          PROTOCOL = "smtps";
          SMTP_ADDR = "vortex.lkekz.de";
          SMTP_PORT = 465;
          FROM = "forgejo@git.hepr.me";
          USER = "forgejo@git.hepr.me";
        };

        # Email (incoming)
        # This can be used for anonymous commiter emails or replying to notifications
        "email.incoming" = {
          ENABLED = true;
          REPLY_TO_ADDRESS = "%{token}@git.hepr.me";
          HOST = "vortex.lkekz.de";
          PORT = 993;
          USE_TLS = true;
          MAILBOX = "INBOX";
          DELETE_HANDLED_MESSAGE = false;
          USERNAME = "forgejo@git.hepr.me";
        };
      };
      
      # Just like settings, but the values are loaded from file paths
      secrets = {
        mailer.PASSWD = hostConfig.age.secrets.forgejo-email-password.path;
        "email.incoming".PASSWORD = hostConfig.age.secrets.forgejo-email-password.path;
      };
    };

    # See https://wiki.nixos.org/wiki/Forgejo#Ensure_users
    systemd.services.forgejo.preStart = let
      adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
      passwordFile = hostConfig.age.secrets.forgejo-password.path;
      inherit (inputs.personal-data.data.home.git) userName userEmail; # Note, Forgejo doesn't allow creation of an account named "admin"
    in ''
      # Create the admin user
      # This may fail if the user already exists, which is fine.
      ${adminCmd} create --admin \
        --email "${userEmail}" \
        --username "${userName}" \
        --password "$(tr -d '\n' < ${passwordFile})" \
        --must-change-password=false \
        || true
      # Set the password for the admin user
      # The user should exist at this point, if not, it's an error.
      ${adminCmd} change-password \
        --username "${userName}" \
        --password "$(tr -d '\n' < ${passwordFile})" \
        --must-change-password=false
    '';
  };

  age.secrets.forgejo-password = {
    rekeyFile = "${inputs.self.outPath}/secrets/forgejo-password.age";
    path = "${microvmSecretsDir}/forgejo-password";
    symlink = false; # Required since the vm can't see the target if it's a symlink
    mode = "600"; # Allow the VM's root to chown it for forgejo user
    owner = "microvm";
    group = "kvm";
  };

  age.secrets.forgejo-email-password = {
    rekeyFile = "${inputs.self.outPath}/secrets/forgejo-email-password.age";
    path = "${microvmSecretsDir}/forgejo-email-password";
    symlink = false; # Required since the vm can't see the target if it's a symlink
    mode = "600"; # Allow the VM's root to chown it for forgejo user
    owner = "microvm";
    group = "kvm";
  };
}
