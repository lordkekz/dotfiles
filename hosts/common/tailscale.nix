# My Tailscale config.
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      # Allows access via routes to internal IPs advertised by other nodes. (gateway)
      "--accept-routes"
    ];
    authKeyFile = "/home/hpreiser/Downloads/tsauthkey";
  };
}
