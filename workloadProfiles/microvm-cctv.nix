{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: let
  vmName = "cctv";
  vmId = "17";
in {
  services.caddy.virtualHosts."frigate.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.${vmId}:80
  '';

  microvm.vms.${vmName}.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {inherit personal-data vmName vmId;})];

    microvm.balloonMem = lib.mkForce 2048; # MiB

    networking.firewall.interfaces."vm-${vmName}-a".allowedTCPPorts = [22 80];

    services.frigate = {
      enable = true;
      settings.cameras = {};
      hostname = "frigate.hepr.me";
    };
  };
}
