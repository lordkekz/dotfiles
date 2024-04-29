# Enable Hyprland WM
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
}: {
  imports = [
    nixosProfiles.graphical
    inputs.hyprland.nixosModules.default
  ];

  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages.${system}.hyprland;
}
