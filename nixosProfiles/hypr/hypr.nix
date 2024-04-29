# Enable Hyprland WM
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
  imports = [nixosProfiles.graphical];

  programs.hyprland.enable = true;
}
