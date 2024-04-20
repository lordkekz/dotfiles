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
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    # The defaults set by home-manager are fine.
    # But I want home-manager to define the paths
    # because it otherwise depends on installation language. (And thus breaks other stuff)
  };
}
