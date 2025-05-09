# Each host generates its own certificates for domains supporting dns-01 challenge
{
  inputs,
  outputs,
  nixosProfiles,
  lib,
  config,
  pkgs,
  ...
}: let
  cloudflare = domain: {
    inherit domain;
    extraDomainNames = ["*.${domain}"];
    dnsProvider = "cloudflare";
    # location of your CLOUDFLARE_DNS_API_TOKEN=[value]
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#EnvironmentFile=
    environmentFile = config.age.secrets.cloudflare-token.path;
  };
in {
  security.acme = {
    acceptTerms = true;
    defaults.email = "info@lkekz.de";
    certs = {
      "heinrich-preiser.de" = cloudflare "heinrich-preiser.de";
      "hepr.me" = cloudflare "hepr.me";
      "drafts.hepr.me" = cloudflare "drafts.hepr.me";
      "solux.cc" = cloudflare "solux.cc";
    };
  };

  age.secrets.cloudflare-token.rekeyFile = "${inputs.self.outPath}/secrets/cloudflare-token.age";
}
