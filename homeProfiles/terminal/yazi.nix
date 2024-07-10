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
      manager = {
        show_hidden = true;
        sort_dir_first = true;
        linemode = "mtime";
        scrolloff = 4;
      };
    };
    keymap = let
      inherit (lib) concatLists attrValues genList;
      inherit (builtins) toString;

      keymap.tabs =
        [
          {
            on = ["t" "t"];
            run = "tab_create --current";
            desc = "Create a new tab using the current path";
          }
          {
            on = ["t" "x"];
            run = "tab_close --current";
            desc = "Close current tab";
          }
          {
            on = ["t" "b"];
            run = "tab_switch -1 --relative";
            desc = "Switch to the previous tab";
          }
          {
            on = ["t" "n"];
            run = "tab_switch 1 --relative";
            desc = "Switch to the next tab";
          }
        ]
        ++ (genList (i: {
            on = ["t" (toString (i + 1))];
            run = "tab_switch ${toString i}";
            desc = "Switch to tab ${toString (i + 1)}";
          })
          9);

      keymap.relative-motions =
        genList (i: {
          on = [(toString (i + 1))];
          run = "plugin relative-motions --args=${toString (i + 1)}";
          desc = "Move in relative steps";
        })
        9;

      keymap.general = [
        {
          on = ["<Enter>"];
          run = "plugin bypass --args=smart_enter";
          desc = "Open a file, or recursively enter child directory, skipping children with only a single subdirectory";
        }
        {
          on = ["l"];
          run = "plugin bypass --args=smart_enter";
          desc = "Open a file, or recursively enter child directory, skipping children with only a single subdirectory";
        }
        {
          on = ["h"];
          run = "plugin bypass --args=reverse";
          desc = "Recursively enter parent directory, skipping parents with only a single subdirectory";
        }
      ];
    in {
      manager.prepend_keymap = concatLists (attrValues keymap);
    };

    plugins = with pkgs.yaziPlugins; {
      inherit bypass relative-motions starship;
    };
  };

  xdg.configFile = {
    "yazi/init.lua".text = ''
      require("starship"):setup()
      require("relative-motions"):setup({ show_numbers="relative_absolute", show_motion = true })
    '';
  };
}
