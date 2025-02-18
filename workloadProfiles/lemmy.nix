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

  services.postgresql = {
    dataDir = "/persist/postgres";
  };
  services.postgresqlBackup = {
    databases = [config.services.lemmy.settings.database.database];
    # No compression = Easy deduplication of backups
    compression = "none";
    # This is backed up by borgbackup
    location = "/persist/postgresBackup";
  };
}
