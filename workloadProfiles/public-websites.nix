{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: {
  services.caddy.virtualHosts."heinrich-preiser.de" = {
    serverAliases = ["www.heinrich-preiser.de"];
    extraConfig = ''
      tls /var/lib/acme/heinrich-preiser.de/cert.pem /var/lib/acme/heinrich-preiser.de/key.pem
      header Content-Type text/html
      respond <<HTML
        <html>
          <head><title>heinrich-preiser.de</title></head>
          <body>Site under construction.</body>
        </html>
        HTML 200
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

  services.caddy.virtualHosts."r4c.hepr.me" = {
    serverAliases = ["www.r4c.hepr.me"];
    extraConfig = ''
      tls /var/lib/acme/r4c.hepr.me/cert.pem /var/lib/acme/r4c.hepr.me/key.pem
      redir luna.r4c.hepr.me{uri}
    '';
  };
  services.caddy.virtualHosts."luna.r4c.hepr.me".extraConfig = ''
    tls /var/lib/acme/r4c.hepr.me/cert.pem /var/lib/acme/r4c.hepr.me/key.pem
    reverse_proxy http://localhost:8001 {
      header_down X-Real-IP {http.request.remote}
      header_down X-Forwarded-For {http.request.remote}
    }
  '';
  services.caddy.virtualHosts."luna.r4c.hepr.me:9090".extraConfig = ''
    tls /var/lib/acme/r4c.hepr.me/cert.pem /var/lib/acme/r4c.hepr.me/key.pem
    reverse_proxy http://localhost:9001
  '';

  services.caddy.virtualHosts."robi.r4c.hepr.me".extraConfig = ''
    tls /var/lib/acme/r4c.hepr.me/cert.pem /var/lib/acme/r4c.hepr.me/key.pem
    reverse_proxy http://localhost:8002 {
      header_down X-Real-IP {http.request.remote}
      header_down X-Forwarded-For {http.request.remote}
    }
  '';
  services.caddy.virtualHosts."robi.r4c.hepr.me:9090".extraConfig = ''
    tls /var/lib/acme/r4c.hepr.me/cert.pem /var/lib/acme/r4c.hepr.me/key.pem
    reverse_proxy http://localhost:9002
  '';

  networking.firewall.allowedTCPPorts = [9090];

  # Enable podman containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    extraPackages = [pkgs.podman-compose];
  };
}
