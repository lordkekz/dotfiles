# Config for Hyprpaper, the wallpaper daemon for Hyprland
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
}: let
  inherit (lib) attrValues;
  wp.stylix = toString config.stylix.image;
  wp.italy = "${../../assets/wallpaper-italy.jpg}";
  wp.normandie = "${../../assets/wallpaper-normandie.jpg}";
  wp.un1 = "/home/hpreiser/Downloads/chris-czermak-PamFFHL6fVY-unsplash.jpg";
  wp.un2 = "/home/hpreiser/Downloads/mike-yukhtenko-wfh8dDlNFOk-unsplash.jpg";
in {
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = true;
      splash_offset = 2.0; # how far (in % of height) up should the splash be displayed
      preload = attrValues wp;
      wallpaper = [
        "eDP-1,${wp.stylix}"
        "DP-1,${wp.stylix}"
        ",${wp.stylix}"
      ];
    };
  };
}
