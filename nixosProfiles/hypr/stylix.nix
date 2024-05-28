# Use stylix system-wide
args @ {
  inputs,
  outputs,
  nixosProfiles,
  lib,
  config,
  system,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  ...
}: let
in {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    image = args.stylix-image;
    polarity = "dark"; # "light" "either" "dark"
    targets.plymouth.enable = false;
  };
}
