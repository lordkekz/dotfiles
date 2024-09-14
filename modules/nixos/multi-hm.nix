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
        log_file=/tmp/home-manager-activation-${name}.log
        { ${value.homeConfiguration.activationPackage}/activate -b backup | tee "$log_file"; } ||
        {
          echo "FAILED TO ACTIVATE!!!" | tee -a "$log_file";
          {
            sleep 5;
            rm ~/.gtkrc-2.0;
            ${value.homeConfiguration.activationPackage}/activate -b backup2 | tee -a "$log_file";
          } &
        }

        # Launch the actual session
        ${value.launchCommand}
      '';
    };

  mkDesktopFileForSession = name: value:
    pkgs.makeDesktopItem {
      # Path relative to $out/share/applications
      name = "multi-hm-session-${name}";
      desktopName = value.displayName;
      exec = "${getExe (mkLaunchScript name value)}";
    };

  mkLinkToDesktopFile = name: value: "ln -sT ${mkDesktopFileForSession name value}/share/applications/multi-hm-session-${name}.desktop $out/share/wayland-sessions/${name}.desktop";

  wayland-sessions = pkgs.runCommandLocal "multi-hm-sessions" {passthru.providedSessions = attrNames cfg;} ''
    mkdir -p "$out/share/xsessions" # Will not be populated because I don't use X11 anymore.
    mkdir -p "$out/share/wayland-sessions"
    ${pipe cfg [
      (mapAttrsToList mkLinkToDesktopFile)
      concatLines
    ]}
  '';
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
        options.displayName = mkOption {
          description = ''
            Session name to display in display manager.
          '';
          type = str;
        };
      });
  };

  config = {
    services.displayManager.sessionPackages = [wayland-sessions];
    environment.systemPackages = mapAttrsToList mkLaunchScript cfg;
  };
}
