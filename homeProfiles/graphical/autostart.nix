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
  home.file = mkAutostart (
    [
      "discord"
      #"element-desktop"
      #"obsidian"
      #"org.telegram.desktop"
      "signal-desktop"
    ]
    ++ (
      if config.wayland.windowManager.hyprland.enable
      then [
        "thunderbird" # Birdtray is broken on Hyprland
        "syncthingtray" # Unlike Plasmoid for KDE, the tray icon doesn't start on its own
      ]
      else [
        "com.ulduzsoft.Birdtray"
      ]
    )
  );
}
