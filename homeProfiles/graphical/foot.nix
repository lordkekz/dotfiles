# foot terminal
args @ {
  inputs,
  outputs,
  personal-data,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  system,
  lib,
  config,
  ...
}: {
  programs.foot = {
    enable = true;
    settings = {
      # General stuff
      main = {
        shell = "${config.programs.tmux.package}/bin/tmux attach";

        # Window options
        initial-window-mode = "maximized";
        pad = "4x4center";
        resize-by-cells = "no"; # Allow window size to not be a multiple of cell size
        resize-keep-grid = "no"; # Keep window dimensions when font size changes
      };

      bell = {
        urgent = "yes";
        notify = "yes"; # Does nothing because desktop-notifications.command is unset
        visual = "yes";
        # Play bell souhd. This is analogous to the command in alacritty.nix
        # command = "${pkgs.vlc}/bin/cvlc --play-and-exit ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/bell.oga";
        command-focused = "yes";
      };

      scrollback.lines = 10000;

      url = {};
      cursor = {};

      mouse.hide-when-typing = "yes";

      touch = {};

      # Try not to use client-side decorations
      csd.preferred = "server";

      key-bindings = {};
      search-bindings = {};
      url-bindings = {};
      text-bindings = {};
      mouse-bindings = {};
    };
  };
}
