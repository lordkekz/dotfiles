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
    isSystemUser = true;
    group = "nogroup";
    openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8hxNHWcHNcSFEQ8dDhGeykudU4DdkN3rqdMJmjLSNJ''
    ];
  };

  services.caddy.virtualHosts."heinrich-preiser.de" = {
    serverAliases = ["www.heinrich-preiser.de"];
    extraConfig = ''
      tls /var/lib/acme/heinrich-preiser.de/cert.pem /var/lib/acme/heinrich-preiser.de/key.pem

      @www-subdomain host www.heinrich-preiser.de
      redir @www-subdomain https://heinrich-preiser.de{uri} permanent

      root * /var/www/heinrich-preiser-de/prod
      file_server
    '';
  };

  services.caddy.virtualHosts."hepr.me" = {
    serverAliases = ["www.hepr.me"];
    extraConfig = ''
      tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
      header Content-Type text/html
      respond <<HTML
        <html>
          <head><title>hepr.me</title></head>
          <body>Site under construction.</body>
        </html>
        HTML 200
    '';
  };

  services.caddy.virtualHosts."solux.cc" = {
    serverAliases = ["www.solux.cc"];
    extraConfig = ''
      tls /var/lib/acme/solux.cc/cert.pem /var/lib/acme/solux.cc/key.pem
      header Content-Type text/html
      respond <<HTML
        <html>
          <head><title>solux.cc</title></head>
          <body>Site under construction.</body>
        </html>
        HTML 200
    '';
  };

  # Enable podman containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    extraPackages = [pkgs.podman-compose];
  };
}
