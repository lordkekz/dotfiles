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
  };
  networking.firewall.allowedTCPPorts = [80 443];
}
