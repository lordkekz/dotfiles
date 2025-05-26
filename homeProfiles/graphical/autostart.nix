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
        "autostart-${lib.replaceStrings ["/"] ["-"] currentAppName}" = {
          target = ".config/autostart/${currentAppName}.desktop";
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix-profile/share/applications/${currentAppName}.desktop";
        };
      })
    {}
    appDesktopNames;

  # FIXME replace mkAutostart with this after upgrade to 25.05
  # mkAbsoluteIfNeeded = map (name:
  #   if lib.hasPrefix "/" name
  #   then name
  #   else "${config.home.homeDirectory}/.nix-profile/share/applications/${name}.desktop");

  tailscaleSystrayDesktopEntry = pkgs.makeDesktopItem {
    name = "tailscale-systray";
    desktopName = "Tailscale Systray";
    exec = "${lib.getExe pkgs.tailscale-systray}";
  };
  tailscaleSystrayAutostart = "${tailscaleSystrayDesktopEntry}/share/applications/tailscale-systray.desktop";
in {
  home.file =
    mkAutostart ([
        "element-desktop"
        # "obsidian"
        # "org.telegram.desktop"
        "feishin"
      ]
      ++ optionals (! config.wayland.windowManager.hyprland.enable) [
        # "discord"
        "com.ulduzsoft.Birdtray"
        "signal"
      ])
    // {
      "autostart-tailscale-systray" = {
        target = ".config/autostart/tailscale-systray.desktop";
        source = tailscaleSystrayAutostart;
      };
    };
}
