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
    guiAddress = "0.0.0.0:8384"; # FIXME this port is not opened in firewall, but still undesirable to bind like that
    user = "acme"; # FIXME this is a hack because of permissions issues.
    key = config.age.secrets.syncthing-key.path;
    cert = config.age.secrets.syncthing-cert.path;
    inherit (personal-data.data.lab.syncthing.settings) devices folders;
  };

  age.secrets.syncthing-key.rekeyFile = "${inputs.self.outPath}/secrets/syncthing-${config.system.name}-key.pem.age";
  age.secrets.syncthing-cert.rekeyFile = "${inputs.self.outPath}/secrets/syncthing-${config.system.name}-cert.pem.age";
}
