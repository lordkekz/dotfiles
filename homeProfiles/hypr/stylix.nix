# Stylix for home manager
args @ {
  inputs,
  outputs,
  homeProfiles,
  personal-data,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  system,
  lib,
  config,
  ...
}: {
  imports = [
    inputs.stylix.homeManagerModules.stylix
  ];

  stylix = {
    image = ../../assets/wallpaper-normandie.jpg;
    polarity = "dark";
    targets.alacritty.enable = false;
    targets.gtk.enable = true;
  };
}
