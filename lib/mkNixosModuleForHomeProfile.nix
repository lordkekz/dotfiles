{
  self,
  super,
  root,
  lib,
  flake,
}: let
  hl = flake.inputs.haumea.lib;

  inherit (flake.inputs.personal-data.data.home) username;

  # mkNixosModulesForHomeProfiles :: set of (home-manager module) -> set of (nixos module)
  mkNixosModuleForHomeProfile = homeConfiguration: args @ {
    config,
    lib,
    pkgs,
    utils,
    ...
  }: let
    serviceEnvironment = {};
    inherit (lib) concatStringsSep;
  in {
    systemd.services = let
      usercfg = homeConfiguration.config;
      username = usercfg.home.username;
    in {
      "home-manager-${utils.escapeSystemdPath username}" = {
        description = "Home Manager environment for ${username}";
        wantedBy = ["multi-user.target"];
        wants = ["nix-daemon.socket"];
        after = ["nix-daemon.socket"];
        before = ["systemd-user-sessions.service"];

        environment = serviceEnvironment;

        unitConfig = {RequiresMountsFor = usercfg.home.homeDirectory;};

        stopIfChanged = false;

        serviceConfig = {
          User = usercfg.home.username;
          Type = "oneshot";
          RemainAfterExit = "yes";
          TimeoutStartSec = "5m";
          SyslogIdentifier = "hm-activate-${username}";

          ExecStart = let
            systemctl = "XDG_RUNTIME_DIR=\${XDG_RUNTIME_DIR:-/run/user/$UID} systemctl";

            sed = "${pkgs.gnused}/bin/sed";

            exportedSystemdVariables = concatStringsSep "|" [
              "DBUS_SESSION_BUS_ADDRESS"
              "DISPLAY"
              "WAYLAND_DISPLAY"
              "XAUTHORITY"
              "XDG_RUNTIME_DIR"
            ];

            setupEnv = pkgs.writeScript "hm-setup-env" ''
              #! ${pkgs.runtimeShell} -el

              # The activation script is run by a login shell to make sure
              # that the user is given a sane environment.
              # If the user is logged in, import variables from their current
              # session environment.
              eval "$(
                ${systemctl} --user show-environment 2> /dev/null \
                | ${sed} -En '/^(${exportedSystemdVariables})=/s/^/export /p'
              )"

              exec "$1/activate"
            '';
          in "${setupEnv} ${usercfg.home.activationPackage}";
        };
      };
    };
  };
in
  mkNixosModuleForHomeProfile
