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
  inherit (lib) optionals;

  mkAutostart = appDesktopNames:
    builtins.foldl' (autostartLinks: currentAppName:
      autostartLinks
      // {
        "autostart-${currentAppName}" = {
          target = ".config/autostart/${currentAppName}.desktop";
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix-profile/share/applications/${currentAppName}.desktop";
        };
      })
    {}
    appDesktopNames;
in {
  home.file = mkAutostart (
    [
      "element-desktop"
      # "obsidian"
      # "org.telegram.desktop"
      "feishin"
    ]
    ++ (optionals (! config.wayland.windowManager.hyprland.enable) [
      # "discord"
      "com.ulduzsoft.Birdtray"
      "signal-desktop"
    ])
  );
}
