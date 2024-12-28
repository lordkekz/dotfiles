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
      "git.hepr.me"
    ];

    virusScanning = true;
    hierarchySeparator = "/";
    useFsLayout = true;

    fullTextSearch = {
      enable = true;
      memoryLimit = 1500; # MiB
    };

    # Put all persistent data in its own subvolume for easy backups
    mailDirectory = "/persist/mail/vmail";
    sieveDirectory = "/persist/mail/sieve";
    dkimKeyDirectory = "/persist/mail/dkim";
    indexDir = "/persist/mail/indices";

    inherit (personal-data.data.lab.mailserver) loginAccounts;

    certificateScheme = "acme";
  };
}
