# Programs to enable on all my configurations
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
  # Enable Incus Linux containers
  virtualisation.incus.enable = true;

  # Enable podman containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };
}
