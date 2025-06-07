{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: {
  services.caddy.virtualHosts."jellyfin.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy :8096
  '';

  services.jellyfin = {
    enable = true;
    # These directories provided by disko
    dataDir = "/var/lib/jellyfin";
    cacheDir = "/var/cache/jellyfin";
  };

  systemd.services.jellyfin.serviceConfig.After = ["zfs-mount.service"];
}
