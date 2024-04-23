# Create symlinks to autostart some apps
args @ {
  inputs,
  outputs,
  personal-data,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  system,
  lib,
  config,
  ...
}: let
  mkAutostart = appDesktopNames:
    builtins.foldl' (autostartLinks: currentAppName:
      autostartLinks
      // {
        "autostart-${currentAppName}" = {
          target = "${config.home.homeDirectory}/.config/autostart/${currentAppName}.desktop";
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix-profile/share/applications/${currentAppName}.desktop";
        };
      })
    {}
    appDesktopNames;
in {
  home.file = mkAutostart [
    "com.ulduzsoft.Birdtray"
    "discord"
    #"element-desktop"
    #"obsidian"
    #"org.telegram.desktop"
    "signal-desktop"
    # "syncthingtray" # starts automatically anyways; gives error if started before tray is available.
  ];
}
