# My Hyprland Desktop configuration
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
in {
  imports = [
    homeProfiles.graphical
    inputs.hyprland.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    libsForQt5.kwalletmanager
    playerctl
    wl-clipboard
  ];

  services.cliphist.enable = true;
  services.playerctld.enable = true;
  services.dunst.enable = true;
  services.udiskie.enable = true;
  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;
}
