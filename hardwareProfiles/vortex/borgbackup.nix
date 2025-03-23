{
  inputs,
  personal-data,
  lib,
  config,
  pkgs,
  ...
}: {
  services.borgbackup.jobs = {
    backup-to-nasman-orion = let
      passphrasePath = config.age.secrets.borgbackup-passphrase-orion.path;
      identityPath = config.age.secrets.borgbackup-key-vortex.path;
      knownHostsPath = pkgs.writeText "borgbackup-to-nasman-orion-known_hosts" ''
        [nasman2404]:4286 ${personal-data.data.lab.hosts.nasman.key}
      '';
    in {
      paths = [
        "/persist/mail"
        # Only backup the DB dumps. Restoring them will need to be done manually.
        "/persist/postgresBackup"
        # Pictures of Lemmy instance
        "/persist/pict-rs"
      ];
      doInit = true;
      repo = "borg@nasman2404:.";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${passphrasePath}";
      };
      environment.BORG_RSH = "ssh -p 4286 -i ${identityPath} -o 'UserKnownHostsFile=${knownHostsPath}'";
      compression = "auto,lzma";
      startAt = "daily";
    };
  };

  age.secrets = {
    borgbackup-key-vortex.rekeyFile = "${inputs.self.outPath}/secrets/borgbackup-key-vortex.age";
    borgbackup-passphrase-orion.rekeyFile = "${inputs.self.outPath}/secrets/borgbackup-passphrase-orion.age";
  };
}
