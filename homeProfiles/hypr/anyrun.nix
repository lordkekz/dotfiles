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
    #package = anyrunPkgs.anyrun-with-all-plugins;
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
      x.fraction = 0.5; # centered
      y.fraction = 0.15;
      width.fraction = 0.3; # fraction of screen
      height.absolute = 32; # pixels
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = true;
      closeOnClick = true;
      showResultsImmediately = false;
      maxEntries = null;
    };

    extraCss = builtins.readFile ./anyrun.css;

    extraConfigFiles."applications.ron".text = ''
      Config(
          // Also show the Desktop Actions defined in the desktop files, e.g. "New Window" from LibreWolf
          desktop_actions: false,
          max_entries: 5,
          // The terminal used for running terminal based desktop entries, if left as `None` a static list of terminals is used
          // to determine what terminal to use.
          terminal: Some("alacritty"),
      )
    '';

    extraConfigFiles."dictionary.ron".text = ''
      Config(
        prefix: ":def",
        max_entries: 5,
      )
    '';

    # FIXME package kidex using Nix, create home-manager module and use that
    extraConfigFiles."kidex.ron".text = ''
      Config(
        max_entries: 5,
      )
    '';

    extraConfigFiles."randr.ron".text = ''
      Config(
        prefix: ":dp",
        max_entries: 5,
      )
    '';

    # (rink calculator plugin doesn't have config)

    extraConfigFiles."shell.ron".text = ''
      Config(
        prefix: ":sh",
        // Override the shell used to launch the command
        shell: "${config.programs.nushell.package}/bin/nu",
      )
    '';

    extraConfigFiles."symbols.ron".text = ''
      Config(
        prefix: ":sym",
        // Custom user defined symbols to be included along the unicode symbols
        symbols: {
          // "name": "text to be copied"
          "shrug": "¯\\_(ツ)_/¯",
        },
        max_entries: 3,
      )
    '';

    extraConfigFiles."translate.ron".text = ''
      Config(
        prefix: ":tl",
        language_delimiter: " to ",
        max_entries: 3,
      )
    '';

    extraConfigFiles."websearch.ron".text = ''
      Config(
        prefix: "?",
        // Can also define custom searches, see docs
        engines: [ DuckDuckGo ],
      )
    '';
  };
}
