# Caddy reverse-proxy for vm services
{
  inputs,
  outputs,
  nixosProfiles,
  lib,
  config,
  pkgs,
  ...
}: {
  services.caddy = {
    enable = true;
    group = "acme";
    globalConfig = ''
      debug
      auto_https disable_certs
    '';
    virtualHosts."syncit.hepr.me".extraConfig = ''
      tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
      reverse_proxy http://10.0.0.11:8384
    '';
  };
  networking.firewall.allowedTCPPorts = [80 443];
}
