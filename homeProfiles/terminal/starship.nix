# Use starship as the prompt for my shell
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
  programs.starship = {
    enable = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      # add_newline = false;

      directory.repo_root_style = "bold purple";

      status = rec {
        disabled = false;
        success_symbol = "[󰗼](bold green) "; # nerdfonts nf-md-exit_to_app;
        symbol = "[󰗼](bold red) "; # nerdfonts nf-md-exit_to_app
        style = "regular gray";
      };

      character = {
        success_symbol = "[](bold green)"; # nerdfonts nf-fa-caret_right
        error_symbol = "[](bold red)"; # nerdfonts nf-fa-caret_right
      };

      sudo = {
        disabled = false;
        style = "bold yellow";
        format = "is [$symbol]($style)";
        symbol = "󰢏 privileged "; # nerdfonts nf-md-shield_account
      };

      cmd_duration = {
        disabled = false;
        min_time = 500; # ms
      };

      # package.disabled = true;
    };
  };
}
