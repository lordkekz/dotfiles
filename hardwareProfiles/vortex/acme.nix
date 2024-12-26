# Generate ACME certs for my domains
# FIXME remove this pls
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
  http = domain: {
    inherit domain;
    webroot = "/var/lib/acme";
  };
in {
  security.acme = {
    acceptTerms = true;
    defaults.email = "info@lkekz.de";
    certs = {
      "hepr.me" = cloudflare "hepr.me";
      "r4c.hepr.me" = cloudflare "r4c.hepr.me";
      "solux.cc" = cloudflare "solux.cc";
      "vortex.lkekz.de" = http "vortex.lkekz.de";
    };
  };

  services.caddy.virtualHosts.":80/.well-known/acme-challenge/*".extraConfig = ''
    root * /var/lib/acme/.well-known/acme-challenge
  '';

  age.secrets.cloudflare-token.rekeyFile = "${inputs.self.outPath}/secrets/cloudflare-token.age";
}
