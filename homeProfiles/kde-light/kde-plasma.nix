# My config for KDE Plasma 6, but in light mode
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
  imports = [homeProfiles.kde "${inputs.self.outPath}/stylix-light.nix"];
}
