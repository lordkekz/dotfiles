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
        pad = "4x4center"; #FIXME test this
      };

      bell = {
        urgent = "no";
        notify = "yes";
        visual = "yes";
        # command = ...; # TODO maybe configure command based on alacritty
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
