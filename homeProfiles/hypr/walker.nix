# My config for Walker, a Wayland-Native runner.
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
  imports = [inputs.walker.homeManagerModules.walker];

  programs.walker = {
    enable = true;
    runAsService = true;

    # All options from the config.json can be used here.
    config = {
      placeholder = "Walk anywhere...";
      keep_open = false;
      ignore_mouse = false;
      ssh_host_file = "";
      enable_typeahead = true;
      show_initial_entries = true;
      fullscreen = false;
      scrollbar_policy = "automatic";
      hyprland.context_aware_history = true;
      activation_mode = {
        disabled = false;
        use_f_keys = false;
        use_alt = false;
      };
      search = {
        delay = 0;
        hide_icons = false;
        margin_spinner = 10;
        hide_spinner = false;
      };
      runner.excludes = ["rm"];
      clipboard = {
        max_entries = 25;
        image_height = 300;
      };
      align = {
        ignore_exclusive = true;
        width = 600;
        horizontal = "center";
        vertical = "start";
        anchors = {
          top = false;
          bottom = false;
          left = false;
          right = false;
        };
        margins = {
          top = 0;
          bottom = 0;
          end = 0;
          start = 0;
        };
      };
      list = {
        height = 300;
        margin_top = 10;
        always_show = true;
        hide_sub = false;
      };
      orientation = "vertical";
      icons = {
        theme = "";
        hide = false;
        size = 32;
        image_height = 200;
      };
      modules = [
        {
          name = "runner";
          prefix = ">";
        }
        {
          name = "applications";
          prefix = "";
        }
        {
          name = "ssh";
          prefix = "";
          switcher_exclusive = false;
        }
        {
          name = "finder";
          prefix = "";
          switcher_exclusive = false;
        }
        {
          name = "commands";
          prefix = "";
          switcher_exclusive = false;
        }
        {
          name = "websearch";
          prefix = "?";
        }
        {
          name = "switcher";
          prefix = "/";
        }
      ];
    };

    style = lib.readFile ./walker.css;
  };
}
