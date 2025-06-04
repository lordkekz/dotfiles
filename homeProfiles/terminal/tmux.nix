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
      {
        plugin = outputs.packages.${system}.tmux-matryoshka;
        extraConfig = ''
          set -g @matryoshka_inactive_status_style 'fg=white,bg=#282828'
        '';
      }
    ];
    extraConfig = ''
      # ============================================= #
      # Extra config                                  #
      # --------------------------------------------- #

      # Improve chances that images work. See https://yazi-rs.github.io/docs/image-preview/#tmux-users
      set -g allow-passthrough on
      set -g default-terminal "tmux"
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      # Only show status bar if there is more then one window
      # adapted from: https://schauderbasis.de/posts/hide_tmux_status_bar_if_its_not_needed/
      if "[ #{session_windows} -gt 1 ]" "set status on" "set status off"
      set-hook -g after-new-window      'if "[ #{session_windows} -gt 1 ]" "set status on" "set status off"'
      set-hook -g after-kill-pane       'if "[ #{session_windows} -gt 1 ]" "set status on" "set status off"'
      set-hook -g pane-exited           'if "[ #{session_windows} -gt 1 ]" "set status on" "set status off"'
      set-hook -g window-layout-changed 'if "[ #{session_windows} -gt 1 ]" "set status on" "set status off"'

      # Disable statusbar for ssh or mosh sessions
      # if-shell '[[ -n "$SSH_CLIENT" ]]' "set -g status off"

      # Use muxbar status bar
      set -g status-interval 1
      set -g status-style 'fg=#c8c8c8,bg=black'
      set -g status-left '#[fg=blue] #S '
      set -g status-right-length 200
      set -g status-right '#(${lib.getExe inputs.muxbar.packages.${system}.muxbar})'

      set -g window-status-format "#[default]#I: #W "
      set -g window-status-current-format "#[default,fg=brightyellow]#[bg=brightyellow,fg=black] #I: #W #[default,fg=brightyellow] "

      # Override tinted-tmux using only second-darkest color, which is gray on da-one-black from stylix.
      set -g window-status-style "fg=#c8c8c8"
      set -g window-status-current-style ""

      # Prevent delay when exiting insert mode in modal editors
      # See: https://github.com/helix-editor/helix/issues/2039
      # See: https://neovim.io/doc/user/faq.html#faq-runtime
      #      (under "ESC IN TMUX OR GNU SCREEN IS DELAYED")
      set -g escape-time 0
    '';
  };
}
