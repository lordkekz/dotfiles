# My Tailscale config.
{
  inputs,
  outputs,
  nixosProfiles,
  lib,
  config,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  ...
}: {
  services.tailscale = {
    enable = false;
    useRoutingFeatures = "client";
    extraUpFlags = [
      # Allows access via routes to internal IPs advertised by other nodes. (gateway)
      "--accept-routes"
    ];
    authKeyFile = "/home/hpreiser/Downloads/tsauthkey";
  };
}
