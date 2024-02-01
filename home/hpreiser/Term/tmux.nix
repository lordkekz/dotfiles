# All my terminal-specific user configuration.
args @ {
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  # extraSpecialArgs:
  system,
  username,
  ...
}: {
  programs.tmux = {
    enable = true;
    #package = pkgs.tmux;
    mouse = true;
    shell = "${pkgs.nushell}/bin/nu";
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

    '';
  };
}
