{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: {
  users.users."web-deployments" = {
    # To give it a shell ??
    isNormalUser = true;
    group = "nogroup";
    openssh.authorizedKeys.keys = [
      ''command="${lib.getExe pkgs.rrsync} -wo /var/www/",restrict,from="10.0.0.17" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8hxNHWcHNcSFEQ8dDhGeykudU4DdkN3rqdMJmjLSNJ''
    ];
  };

  services.caddy.virtualHosts = let
    mkPublicWebsite = domain: {
      serverAliases = ["www.${domain}"];
      extraConfig = ''
        tls /var/lib/acme/${domain}/cert.pem /var/lib/acme/${domain}/key.pem

        @www-subdomain host www.${domain}
        redir @www-subdomain https://${domain}{uri} permanent

        root * /var/www/${domain}/prod
        file_server
      '';
    };
    mkDraftWebsite = domain: {
      extraConfig = ''
        tls /var/lib/acme/drafts.hepr.me/cert.pem /var/lib/acme/drafts.hepr.me/key.pem

        @denied not client_ip 192.168.0.0/16 100.80.81.0/24
        respond @denied 200

        root * /var/www/${domain}/test
        file_server
      '';
    };
    mkRedirect = domain: target: {
      extraConfig = ''
        tls /var/lib/acme/${domain}/cert.pem /var/lib/acme/${domain}/key.pem

        @www-subdomain host www.${domain}
        redir @www-subdomain https://${domain}{uri} permanent

        redir * ${target} temporary
      '';
    };
  in {
    "heinrich-preiser.de" = mkPublicWebsite "heinrich-preiser.de";
    "hepr.me" = mkRedirect "hepr.me" "https://heinrich-preiser.de{uri}";
    "solux.cc" = mkPublicWebsite "solux.cc";
    "heinrich-preiser-de.drafts.hepr.me" = mkDraftWebsite "heinrich-preiser.de";
    "hepr-me.drafts.hepr.me" = mkDraftWebsite "hepr.me";
    "solux-cc.drafts.hepr.me" = mkDraftWebsite "solux.cc";
  };

  # Enable podman containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    extraPackages = [pkgs.podman-compose];
  };
}
