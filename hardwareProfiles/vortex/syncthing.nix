# Syncthing config to keep ACME certs up to date
{
  inputs,
  outputs,
  personal-data,
  lib,
  config,
  pkgs,
  ...
}: {
  services.syncthing = {
    enable = true;
    key = config.age.secrets.syncthing-key.path;
    cert = config.age.secrets.syncthing-cert.path;
    inherit (personal-data.data.lab.syncthing.settings) devices folders;
  };

  age.secrets.syncthing-key.rekeyFile = "${inputs.self.outPath}/secrets/syncthing-vortex-key.pem.age";
  age.secrets.syncthing-cert.rekeyFile = "${inputs.self.outPath}/secrets/syncthing-vortex-cert.pem.age";
}
