# Use stylix system-wide
{
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
    image = ../../assets/wallpaper-normandie.jpg;
    polarity = "dark"; # "light" "either" "dark"
    targets.plymouth.enable = false;
  };
}
