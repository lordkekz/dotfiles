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
  users.groups.acme = {};
  services.caddy = {
    enable = true;
    group = "acme";
    globalConfig = ''
      debug
      auto_https disable_certs
      servers {
        trusted_proxies static 100.80.80.1/32 100.80.80.2/32
      }
    '';
  };
  networking.firewall.allowedTCPPorts = [80 443];
}
