{
  inputs,
  outputs,
  lib,
  config,
  system,
  pkgs,
  workloadProfiles,
  ...
}: {
  imports = with workloadProfiles; [
    public-websites
    mailserver
    # owncast # Currently unused; disable to minimize attack surface
  ];

  # PUBLIC MINECRAFT SERVER RUNS ON NASMAN (but forward ports on vortex)
  networking.firewall.allowedTCPPorts = [25565];
  #networking.firewall.allowedUDPPorts = [25565]; # not yet supported by custom tcp proxy

  # Tailscale doesn't seem to like nftables's NAT when the target is another Tailscale node
  # This service runs a simple TCP proxy to forward connections through Tailscale.
  systemd.services.minecraft-tcp-proxy = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    description = "Simple TCP proxy to forward port 25565 to minecraft server over Tailscale";
    script = lib.getExe outputs.packages.${system}.tcp-proxy;
  };

  # Public map URL: map.hepr.me, internal map URL: mcp.hepr.me
  services.caddy.virtualHosts."map.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy https://mcp.hepr.me {
      # Caddy doesn't automatically change the Host header
      header_up Host {upstream_hostport}
    }
  '';

  # Forward caldav.hepr.me to nasman, but use the same SNI matcher for both nasman and vortex.
  services.caddy.virtualHosts."caldav.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy https://nasman.hepr.me
  '';

  # Forward caldav.hepr.me to nasman, but use the same SNI matcher for both nasman and vortex.
  services.caddy.virtualHosts."music.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy https://nasman.hepr.me
  '';
}
