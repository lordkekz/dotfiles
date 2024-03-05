# Generate .desktop files for declaratively created Firefox profiles.
args @ {
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.firefox-desktopfile-per-profile;
in {
  options.my.firefox-desktopfile-per-profile = {
    enable = mkEnableOption (lib.mdDoc "LordKekz's custom module to generate .desktop files for Firefox profiles");
    profileNames = mkOption {
      type = types.listOf types.str;
      description = "A list of the names of firefox profiles for which to generate custom .desktop files";
    };
  };

  config = mkIf cfg.enable {
    xdg.desktopEntries = listToAttrs (map (p: let
        ff-cmd = ''${config.programs.firefox.package}/bin/firefox -p "${p}"'';
      in {
        name = "firefox-profile-${p}";
        value = {
          actions = {
            new-private-window = {
              name = "New Private Window";
              exec = "${ff-cmd} --private-window %U";
            };
            new-window = {
              name = "New Window";
              exec = "${ff-cmd} --new-window %U";
            };
            profile-manager-window = {
              name = "Profile Manager";
              exec = "${ff-cmd} --ProfileManager";
            };
          };
          categories = ["Application" "Network" "WebBrowser"];
          exec = "${ff-cmd} %U";
          genericName = "Web Browser";
          icon = "firefox";
          mimeType = ["text/html" "text/xml" "application/xhtml+xml" "application/vnd.mozilla.xul+xml" "x-scheme-handler/http" "x-scheme-handler/https"];
          name = "Firefox (${p} profile)";
          startupNotify = true;
          settings.StartupWMClass = "firefox";
          terminal = false;
          type = "Application";
        };
      })
      cfg.profileNames);
  };
}
