{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services.borgbackup.jobs = {
    backup-to-nasman-orion = {
      paths = [
        "/persist/mail"
      ];
      doInit = true;
      repo = "borg@nasman2404:/orion/backups/borg";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.borgbackup-passphrase-orion.path}";
      };
      environment.BORG_RSH = "ssh -i ${config.age.secrets.borgbackup-key-vortex.path}";
      compression = "auto,lzma";
      startAt = "daily";
    };
  };

  age.secrets = {
    borgbackup-key-vortex.rekeyFile = "${inputs.self.outPath}/secrets/borgbackup-key-vortex.age";
    borgbackup-passphrase-orion.rekeyFile = "${inputs.self.outPath}/secrets/borgbackup-passphrase-orion.age";
  };
}
