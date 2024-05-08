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
  programs.yazi = {
    enable = true;
    enableNushellIntegration = true;
    package = pkgs-unstable.yazi;
    settings = {
      show_hidden = true;
      sort_dir_first = true;
    };
    keymap = {
      manager.prepend_keymap = [
        {
          on = ["l" "<Enter>"];
          run = "plugin bypass --args=smart_enter";
          desc = "Open a file, or recursively enter child directory, skipping children with only a single subdirectory";
        }
        {
          on = ["h"];
          run = "plugin bypass --args=reverse";
          desc = "Recursively enter parent directory, skipping parents with only a single subdirectory";
        }
      ];
      manager.append_keymap =
        builtins.genList (x: let
          i = builtins.toString x;
        in {
          on = [i];
          run = "plugin relative-motions --args=${i}";
          desc = "Move in relative steps";
        })
        10;
    };
  };

  xdg.configFile =
    {
      "yazi/init.lua".text = ''
        require("starship"):setup()
      '';
    }
    // (builtins.listToAttrs (lib.mapAttrsToList (k: v: {
      name = "yazi/plugins/${k}.yazi";
      value.source = v.outPath;
    }) inputs.nix-yazi-plugins.packages.${system}));
}
