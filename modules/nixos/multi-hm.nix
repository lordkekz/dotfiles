{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.multi-hm.sessions;
  isHomeConfiguration = x: x ? activationPackage && isDerivation x.activationPackage;
  mkLaunchScript = name: value:
    pkgs.writeShellApplication {
      name = "launch-${name}";
      text = ''
        # Activate home-manager config
        ${value.homeConfiguration.activationPackage}/activate

        # Launch the actual session
        ${value.launchCommand}
      '';
    };
  mkDesktopFileForSession = {
    name,
    value,
  }:
    pkgs.makeDesktopItem {
      name = "share/wayland-sessions/multi-hm-session-${name}";
      desktopName = name;
      exec = "${mkLaunchScript name value}";
    };
  desktopFiles = map mkDesktopFileForSession (attrsToList cfg);
in {
  options.multi-hm.sessions = mkOption {
    description = ''
      Sessions for which desktop entries should be created.
    '';
    type = with types;
      attrsOf (submodule {
        options.homeConfiguration = mkOption {
          description = ''
            Home configuration to activate at launch.
            Create using `home-manager.lib.homeManagerConfiguration`.
          '';
          type = addCheck raw isHomeConfiguration;
        };
        options.launchCommand = mkOption {
          description = ''
            The command to be run for launching this session.
          '';
          type = str;
        };
      });
  };

  config = {
    environment.systemPackages = desktopFiles;
  };
}
