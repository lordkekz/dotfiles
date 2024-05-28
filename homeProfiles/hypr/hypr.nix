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

  home.packages = with pkgs;
  with libsForQt5; [
    kwalletmanager
    playerctl
    wl-clipboard
    okular
    gwenview
    elisa
  ];

  programs.zathura = {
    enable = true;
    mappings = {
    };
    options = {
    };
  };

  services.batsignal = {
    enable = true;
    extraArgs = [
      # warning levels
      "-w"
      "25"
      #"-W" "WARNING: Battery below 25%"
      "-c"
      "20"
      #"-C" "CRITICAL: Battery below 20%"
      "-d"
      "15"
      "-D"
      "systemctl suspend"
      # disable battery full level
      "-f"
      "0"
    ];
  };
  services.cliphist = {
    enable = true;
    #allowImages = true;
    #extraOptions = ...;
  };
  services.playerctld.enable = true;
  services.dunst.enable = true;
  services.udiskie.enable = true;
  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;
}
