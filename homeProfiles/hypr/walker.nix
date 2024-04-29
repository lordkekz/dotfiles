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
      placeholder = "Example";
      fullscreen = true;
      list = {
        height = 200;
      };
      modules = [
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

    # If this is not set the default styling is used.
    style = ''
      * {
        color: #dcd7ba;
      }
    '';
  };
}
