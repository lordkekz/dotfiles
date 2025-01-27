{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: {
  networking.firewall.allowedTCPPorts = [9090];

  virtualisation.oci-containers.containers.ros-humble = {
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "ros";
      imageDigest = "sha256:482ae18aa5d4813dd5c59aee9e4cd830eac94c60587f494e9ff343e6aaf3aba3";
      sha256 = "15i7jffmm0w2vkdxcbv9akbn8xalcgc8pg502sdac0svxlflpiig";
      finalImageName = "ros";
      finalImageTag = "humble";
    };
    image = "ros:humble";

    volumes = ["/persist/local/ros:/home/worm"];
  };

  # Enable podman containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    extraPackages = [pkgs.podman-compose];
  };
}
