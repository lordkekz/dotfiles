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

  programs.plasma = {
    enable = true;
  };

  home.packages = [
    # An autotile script for Plasma 6 (even though it's still in libsForQt5)
    pkgs.polonium
  ];

  programs.okular = {
    enable = true;
    general = {
      smoothScrolling = true;
      showScrollbars = true;
      openFileInTabs = true;
      viewContinuous = true;
      #viewMode = "Single"; # not sure what this does
      zoomMode = "autoFit";
      obeyDrm = false;
      mouseMode = "Browse";
    };
    accessibility = {
      highlightLinks = true;
      changeColors = {
        enable = true;
        mode = "InvertLuma";
      };
    };
    performance = {
      enableTransparencyEffects = true;
      memoryUsage = "Aggressive";
    };
  };
}
