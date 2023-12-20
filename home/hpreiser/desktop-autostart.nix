args @ {
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  mode,
  system,
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
    "betterbird"
    "discord"
    "element-desktop"
    "obsidian"
    "org.telegram.desktop"
    "signal-desktop"
    # "syncthingtray" # starts automatically anyways; gives error if started before tray is available.
  ];
}
