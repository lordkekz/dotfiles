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
    baseIndex = 1;
    clock24 = true;
    newSession = true;
    historyLimit = 100000;
    shortcut = "b";
    # prefix = "C-b"
    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      pain-control # Vim-Style hjkl bindings for switching panes
      mode-indicator # Can be used in status bar to indicate the current mode
      outputs.packages.${system}.tmux-matryoshka
      #power-theme # tmux-powerline
    ];
    extraConfig = ''
      # ============================================= #
      # Extra config                                  #
      # --------------------------------------------- #

      # Improve chances that images work. See https://yazi-rs.github.io/docs/image-preview/#tmux-users
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      # Only show status bar if there is more then one window
      # adapted from: https://schauderbasis.de/posts/hide_tmux_status_bar_if_its_not_needed/
      if "[ #{session_windows} -gt 1 ]" "set status on" "set -g status off"
      set-hook -g after-new-window      'if "[ #{session_windows} -gt 1 ]" "set status on"'
      set-hook -g after-kill-pane       'if "[ #{session_windows} -lt 2 ]" "set status off"'
      set-hook -g pane-exited           'if "[ #{session_windows} -lt 2 ]" "set status off"'
      set-hook -g window-layout-changed 'if "[ #{session_windows} -lt 2 ]" "set status off"'

      # Disable statusbar for ssh or mosh sessions
      # if-shell '[[ -n "$SSH_CLIENT" ]]' "set -g status off"

      # Configure matryoshka plugin
      set -g @matryoshka_status_style_option 'status-style'
      set -g @matryoshka_inactive_status_style 'bg=0,fg=238'
    '';
  };
}
