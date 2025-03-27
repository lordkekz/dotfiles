# Generate ACME certs for http-only domains
{
  inputs,
  outputs,
  nixosProfiles,
  lib,
  config,
  pkgs,
  ...
}: let
  http = domain: {
    inherit domain;
    webroot = "/var/lib/acme";
  };
in {
  security.acme.certs."vortex.lkekz.de" = http "vortex.lkekz.de";

  services.caddy.virtualHosts."vortex.lkekz.de-http".hostName = "vortex.lkekz.de:80";
  services.caddy.virtualHosts."vortex.lkekz.de-http".extraConfig = ''
    handle_path /.well-known/acme-challenge/* {
      root /var/lib/acme/.well-known/acme-challenge
      file_server
    }

    handle {
      respond "Not Found" 404
    }
  '';
  services.caddy.virtualHosts."vortex.lkekz.de-https".hostName = "vortex.lkekz.de:443";
  services.caddy.virtualHosts."vortex.lkekz.de-https".extraConfig = ''
    tls /var/lib/acme/vortex.lkekz.de/cert.pem /var/lib/acme/vortex.lkekz.de/key.pem

    handle_path /.well-known/acme-challenge/* {
      root /var/lib/acme/.well-known/acme-challenge
      file_server
    }

    handle {
      respond "Not Found" 404
    }
  '';
}
