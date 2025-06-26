# My config for KDE Plasma 6
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
    homeProfiles.graphical
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  # Enable here because it fails activation elsewhere
  stylix.targets.kde.enable = true;

  programs.plasma = {
    enable = true;
  };

  home.packages = [
    # An autotile script for Plasma 6
    pkgs.polonium
    inputs.kwin-effects-forceblur.packages.${system}.default
  ];

  # The NixOS's firefox package sets this in the wrapper, but my home-manager firefox package takes
  # precedence and ignores it if not explicitly set
  programs.firefox.nativeMessagingHosts = [pkgs.kdePackages.plasma-browser-integration];

  programs.okular = {
    enable = true;
    general = {
      smoothScrolling = true;
      showScrollbars = true;
      openFileInTabs = true;
      viewContinuous = true;
      # Controls which pages to show, e.g. two or overview
      viewMode = "Single";
      zoomMode = "autoFit";
      obeyDrm = false;
      mouseMode = "Browse";
    };
    accessibility = {
      highlightLinks = true;
      changeColors = {
        enable = config.stylix.polarity == "dark";
        mode = "InvertLuma";
      };
    };
    performance = {
      enableTransparencyEffects = true;
      memoryUsage = "Aggressive";
    };
  };
  programs.plasma.configFile."okularrc"."Notification Messages"."presentationInfo" = false;
}
