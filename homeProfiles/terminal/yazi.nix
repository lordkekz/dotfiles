# Yazi is a TUI file manager
args @ {
  inputs,
  outputs,
  homeProfiles,
  personal-data,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  system,
  lib,
  config,
  ...
}: {
  imports = [inputs.nix-yazi-plugins.legacyPackages.${system}.homeManagerModules.default];

  programs.yazi = {
    enable = true;
    enableNushellIntegration = true;
    # This is overridden by overlay from yazi flake
    settings = {
      manager = {
        show_hidden = true;
        sort_dir_first = true;
        linemode = "mtime";
        scrolloff = 4;
      };
    };
    keymap.manager.prepend_keymap = [
      {
        on = "Z";
        run = "plugin fzf";
        desc = "Jump to a file/directory via fzf";
      }
      {
        on = "z";
        run = "plugin zoxide";
        desc = "Jump to a directory via zoxide";
      }
    ];
    yaziPlugins = {
      enable = true;
      # yaziBasePackage = pkgs.yazi;
      plugins = {
        bypass.enable = true;
        chmod.enable = true;
        # fg.enable = true; # I don't use this normally
        full-border.enable = true;
        git.enable = true;
        max-preview.enable = true; # 'R' to maximize
        hide-preview.enable = true; # 'T' to hide
        # jump-to-char.enable = true; # I don't use this normally
        relative-motions = {
          enable = true;
          # Settings passed at plugin setup
          show_numbers = "relative_absolute";
          show_motion = true;
          only_motions = false;
        };
        smart-filter.enable = true; # 'F' replaces yazi builtin
        starship.enable = true;
        # open-with-cmd.enable = true;
        # bookmarks.enable = true;
      };
    };
  };
}
