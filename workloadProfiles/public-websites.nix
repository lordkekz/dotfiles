{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: {
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
  services.caddy.virtualHosts."r4c.hepr.me" = {
    serverAliases = ["www.r4c.hepr.me"];
    extraConfig = ''
      tls /var/lib/acme/r4c.hepr.me/cert.pem /var/lib/acme/r4c.hepr.me/key.pem
        header Content-Type text/html
        respond <<HTML
          <html>
            <head><title>Robot4Care</title></head>
            <body>November Demo is not set up yet.</body>
          </html>
          HTML 200
    '';
  };
}
