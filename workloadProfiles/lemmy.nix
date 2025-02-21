{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: {
  services.lemmy = {
    enable = true;
    settings = {
      hostname = "lemmy.solux.cc";
      email = {
        smtp_server = "vortex.lkekz.de:465";
        smtp_login = "noreply-lemmy@solux.cc";
        smtp_from_address = "noreply-lemmy@solux.cc";
        tls_type = "tls";
      };
      setup = {
        inherit (personal-data.data.lab.lemmy) admin_username admin_email;
        site_name = "Lemmy @ SOLUX";
      };
    };
    smtpPasswordFile = config.age.secrets.lemmy-email-password.path;
    adminPasswordFile = config.age.secrets.lemmy-admin-password.path;
    caddy.enable = true;
    database.createLocally = true;
  };

  age.secrets.lemmy-email-password.rekeyFile = "${inputs.self.outPath}/secrets/lemmy-email-password.age";
  age.secrets.lemmy-admin-password.rekeyFile = "${inputs.self.outPath}/secrets/lemmy-admin-password.age";

  services.caddy.virtualHosts."lemmy.solux.cc".extraConfig = let
    cfg = config.services.lemmy;
  in
    lib.mkForce ''
      handle_path /static/* {
        root * ${cfg.ui.package}/dist
        file_server
      }
      handle_path /static/undefined/* {
        root * ${cfg.ui.package}/dist
        file_server
      }
      handle_path /static/${cfg.ui.package.passthru.commit_sha}/* {
        root * ${cfg.ui.package}/dist
        file_server
      }
      @for_backend {
        path /api/* /pictrs/* /feeds/* /nodeinfo/*
      }
      handle @for_backend {
        reverse_proxy 127.0.0.1:${toString cfg.settings.port}
      }
      @post {
        method POST
      }
      handle @post {
        reverse_proxy 127.0.0.1:${toString cfg.settings.port}
      }
      @jsonld {
        header Accept "application/activity+json"
        header Accept "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\""
      }
      handle @jsonld {
        reverse_proxy 127.0.0.1:${toString cfg.settings.port}
      }
      handle {
        reverse_proxy 127.0.0.1:${toString cfg.ui.port}
      }
    '';

  services.postgresql = {
    dataDir = "/persist/postgres";
  };
  services.postgresqlBackup = {
    enable = true;
    startAt = "*-*-* 23:30:00"; # This runs 30mins before borg backup
    databases = [config.services.lemmy.settings.database.database];
    # No compression = Easy deduplication of backups
    compression = "none";
    # This is backed up by borgbackup
    location = "/persist/postgresBackup";
  };
}
