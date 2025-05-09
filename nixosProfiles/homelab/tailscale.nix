# Tailscale config.
{
  inputs,
  outputs,
  nixosProfiles,
  lib,
  config,
  pkgs,
  ...
}: {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraSetFlags = [
      # Allows access via routes to internal IPs advertised by other nodes. (gateway)
      "--accept-routes"
    ];
    # authKeyFile = config.age.secrets.tailscale-authkey.path;
  };

  # Don't bother, keys keep exiring and re-registering devices is rare
  # age.secrets.tailscale-authkey.rekeyFile = "${inputs.self.outPath}/secrets/tailscale-authkey.age";
}
