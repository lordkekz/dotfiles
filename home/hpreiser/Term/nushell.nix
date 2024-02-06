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
  programs.nushell = {
    enable = true;
    extraEnv = ''
      # Some funky extraEnv from nushell.nix
      #printf $'(ansi green_bold)extraEnv(ansi reset) '
    '';
    extraConfig = ''
      # Some funky extraConfig from nushell.nix
      #printf $'(ansi cyan_bold)extraConfig(ansi reset) '
      $env.config.show_banner = false;
    '';
    extraLogin = ''
      # Some funky extraLogin from nushell.nix
      #printf $'(ansi blue_bold)extraLogin(ansi reset) '
    '';
    environmentVariables = {
      hello_there = ''"obi wan kenobi"'';
    };
    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
      lla = "ls -la";
      gd = "cd ~/git/dotfiles";
    };
  };

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
