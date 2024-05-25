# My config for anyrun, a Wayland-Native runner.
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
  anyrunPkgs = inputs.anyrun.packages.${system};
in {
  imports = [inputs.anyrun.homeManagerModules.anyrun];

  programs.anyrun = {
    enable = true;
    package = anyrunPkgs.anyrun-with-all-plugins;
    config = {
      plugins = with anyrunPkgs; [
        applications
        dictionary
        kidex
        randr
        rink
        shell
        stdin
        symbols
        translate
        websearch
      ];
      x = {fraction = 0.5;}; # centered
      y = {fraction = 0.3;};
      width = {fraction = 0.3;}; # fraction of screen
      height = {absolute = 64;}; # pixels
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = false;
      showResultsImmediately = false;
      maxEntries = null;
    };

    #extraCss = ''
    #  .some_class {
    #    background: red;
    #  }
    #'';

    #extraConfigFiles."some-plugin.ron".text = ''
    #  Config(
    #    // for any other plugin
    #    // this file will be put in ~/.config/anyrun/some-plugin.ron
    #    // refer to docs of xdg.configFile for available options
    #  )
    #'';
  };
}
