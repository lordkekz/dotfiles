# My nushell configuration, along with the starship prompt and carapace completions.
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

      # Specifies how environment variables are:
      # - converted from a string to a value on Nushell startup (from_string)
      # - converted from a value back to a string when running external commands (to_string)
      # Note: The conversions happen *after* config.nu is loaded
      $env.ENV_CONVERSIONS = {
          "PATH": {
              from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
              to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
          }
          "Path": {
              from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
              to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
          }
      }

      source ${./custom-commands.nu}
    '';
    extraLogin = ''
      # Some funky extraLogin from nushell.nix
      #printf $'(ansi blue_bold)extraLogin(ansi reset) '
    '';
    environmentVariables = {
      # Make neovim the default editor
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    shellAliases = let
      dotfiles-dir = "~/git/dotfiles";
    in rec {
      ll = "ls -l";
      la = "ls -a";
      lla = "ls -la";
      which = "which --all"; # Always list all matches
      gd = "cd ${dotfiles-dir}";
      hmSwitch = "home-manager switch -L -v --flake";
      hmDesk = "${hmSwitch} ${dotfiles-dir}#hpreiser@Desk";
      hmTerm = "${hmSwitch} ${dotfiles-dir}#hpreiser@Term";
      osSwitch = "sudo nixos-rebuild switch -L -v --flake ${dotfiles-dir}";
      cat = "bat";
    };
  };

  # Use starship prompt
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
