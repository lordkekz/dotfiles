# Alacritty terminal emulator config.
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
  programs.alacritty = {
    enable = true;
    settings = {
      shell.program = "${config.programs.tmux.package}/bin/tmux"; # references whichever package is used to enable tmux in terminal.nix
      shell.args = ["attach"];

      window = {
        padding = {
          x = 4; # pixels
          y = 4;
        };
        dynamic_padding = true;
        blur = true;
        startup_mode = "Maximized";
      };
      scrolling.history = 10000;

      colors.transparent_background_colors = true;

      bell = {
        animation = "EaseOutExpo";
        duration = 200; # milliseconds
        color = "#000000";
        command.program = "${pkgs.vlc}/bin/cvlc";
        command.args = [
          "--play-and-exit"
          "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/bell.oga"
        ];
      };
      selection.save_to_clipboard = true;
      mouse = {};
      hints = {};
      keyboard = {};
    };
  };
}
