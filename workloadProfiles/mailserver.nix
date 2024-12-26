{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: {
  imports = [inputs.nixos-mailserver.nixosModule];

  mailserver = {
    enable = true;
    fqdn = "vortex.lkekz.de";
    domains = [
      "heinrich-preiser.de"
      "hepr.me"
      #"git.hepr.me"
    ];

    virusScanning = true;
    hierarchySeparator = "/";
    useFsLayout = true;

    # Put all persistent data in its own subvolume for easy backups
    mailDirectory = "/persist/mail/vmail";
    sieveDirectory = "/persist/mail/sieve";
    dkimKeyDirectory = "/persist/mail/dkim";
    indexDir = "/persist/mail/indices";

    inherit (personal-data.data.lab.mailserver) loginAccounts;

    # TODO test this or maybe use "manual"
    certificateScheme = "acme";
  };
}
