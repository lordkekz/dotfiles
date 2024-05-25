# based on home-manager 24.05-pre
# modified to use custom lib so it works on 23.11
{
  config,
  pkgs,
  inputs,
  ...
}: let
  hmu = inputs.home-manager-unstable;
  lib = hmu.inputs.nixpkgs.lib // hmu.lib;

  cfg = config.services.hypridle;
in
  with lib; {
    meta.maintainers = [maintainers.khaneliman maintainers.fufexan];

    options.services.hypridle = {
      enable = mkEnableOption "Hypridle, Hyprland's idle daemon";

      package = mkPackageOption pkgs "hypridle" {};

      settings = lib.mkOption {
        type = with lib.types; let
          valueType =
            nullOr (oneOf [
              bool
              int
              float
              str
              path
              (attrsOf valueType)
              (listOf valueType)
            ])
            // {
              description = "Hypridle configuration value";
            };
        in
          valueType;
        default = {};
        description = ''
          Hypridle configuration written in Nix. Entries with the same key
          should be written as lists. Variables' and colors' names should be
          quoted. See <https://wiki.hyprland.org/Hypr-Ecosystem/hypridle/> for more examples.
        '';
        example = lib.literalExpression ''
          {
            general = {
              after_sleep_cmd = "hyprctl dispatch dpms on";
              ignore_dbus_inhibit = false;
              lock_cmd = "hyprlock";
            };

            listener = [
              {
                timeout = 900;
                on-timeout = "hyprlock";
              }
              {
                timeout = 1200;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on";
              }
            ];
          }
        '';
      };

      importantPrefixes = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["$"];
        example = ["$"];
        description = ''
          List of prefix of attributes to source at the top of the config.
        '';
      };
    };

    config = mkIf cfg.enable {
      xdg.configFile."hypr/hypridle.conf" = mkIf (cfg.settings != {}) {
        text = lib.hm.generators.toHyprconf {
          attrs = cfg.settings;
          inherit (cfg) importantPrefixes;
        };
      };

      systemd.user.services.hypridle = {
        Install = {WantedBy = ["graphical-session.target"];};

        Unit = {
          ConditionEnvironment = "WAYLAND_DISPLAY";
          Description = "hypridle";
          After = ["graphical-session-pre.target"];
          PartOf = ["graphical-session.target"];
          X-Restart-Triggers = ["${config.xdg.configFile."hypr/hypridle.conf".source}"];
        };

        Service = {
          ExecStart = "${getExe cfg.package}";
          Restart = "always";
          RestartSec = "10";
        };
      };
    };
  }
