# My tmux configuration
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
  programs.tmux = {
    enable = true;
    #package = pkgs.tmux;
    mouse = true;
    shell = "${config.programs.nushell.package}/bin/nu";
    keyMode = "vi";
    clock24 = true;
    newSession = true;
    historyLimit = 100000;
    shortcut = "b";
    # prefix = "C-b"
    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      pain-control # Vim-Style hjkl bindings for switching panes
      mode-indicator # Can be used in status bar to indicate the current mode
      power-theme # tmux-powerline
    ];
    extraConfig = ''
      # Improve chances that images work. See https://yazi-rs.github.io/docs/image-preview/#tmux-users
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM
    '';
  };
}
