# My nushell configuration
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
    in {
      ll = "ls -l";
      la = "ls -a";
      lla = "ls -la";
      which = "which --all"; # Always list all matches
      gd = "cd ${dotfiles-dir}";
      gr = "cd (git root)";
      cat = "bat";
      mm = "tmatrix -C yellow -c black -g 20,80 -l 1,40 -r 10,30 -s 10 -f 0.2,1.0";
    };
  };
}
