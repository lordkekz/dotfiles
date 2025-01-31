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
      "solux.cc"
    ];

    virusScanning = true;
    hierarchySeparator = "/";
    useFsLayout = true;

    fullTextSearch = {
      enable = true;
      memoryLimit = 1500; # MiB
    };

    # If enabled, this files messages to e.g. name+topic@hepr.me in a folder named "topic".
    # That's cool, but it allows senders to create new folders, and these don't appear immediately in Thunderbird.
    # TODO figure out how to fix that
    lmtpSaveToDetailMailbox = "no";

    # Put all persistent data in its own subvolume for easy backups
    mailDirectory = "/persist/mail/vmail";
    sieveDirectory = "/persist/mail/sieve";
    dkimKeyDirectory = "/persist/mail/dkim";
    indexDir = "/persist/mail/indices";

    inherit (personal-data.data.lab.mailserver) loginAccounts;

    certificateScheme = "acme";
  };
}
