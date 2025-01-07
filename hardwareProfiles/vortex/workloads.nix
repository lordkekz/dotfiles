{
  inputs,
  lib,
  config,
  pkgs,
  workloadProfiles,
  ...
}: {
  imports = with workloadProfiles; [
    public-websites
    mailserver
  ];

  # PUBLIC MINECRAFT SERVER RUNS ON NASMAN (but forward ports on vortex)
  networking.firewall.allowedTCPPorts = [25565];
  networking.nftables.ruleset = ''
    table ip nat {
      chain PREROUTING {
        type nat hook prerouting priority dstnat; policy accept;
        tcp dport 25565 dnat to 100.80.80.2:25566
      }
    }
  '';
  # Public mal URL: map.hepr.me, internal map URL: mcp.hepr.me
  services.caddy.virtualHosts."map.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy https://mcp.hepr.me
  '';
}
