{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: let
  port = 8800;
  rtmp-port = 1935; # default
in {
  services.caddy.virtualHosts."live-admin.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem

    @external not client_ip 100.80.81.0/24
    handle @external {
      respond "" 200
    }

    handle {
      reverse_proxy :${builtins.toString port} {
        header_up Host {upstream_hostport}
      }
    }
  '';
  services.caddy.virtualHosts."live.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem

    handle /admin* {
      respond "Not Found" 404
    }

    handle {
      basic_auth {
        ${lib.concatLines (lib.attrValues (lib.mapAttrs
      (user: pw: "${user} ${pw}")
      personal-data.data.lab.owncast.users))}
      }
      reverse_proxy :${builtins.toString port} {
        header_up Host {upstream_hostport}
        header_up X-Forwarded-User {http.auth.user.id}
      }
    }
  '';

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [rtmp-port];

  services.owncast = {
    enable = true;
    listen = "0.0.0.0";
    openFirewall = false;
    inherit port rtmp-port;
    # dataDir is default and not backed up, but persisted using impermanence
    #dataDir = "/var/lib/owncast";
  };
}
