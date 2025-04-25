# Syncthing and syncthingtray
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
}: {
  # Syncthing's settings and folders are configured in NixOS config
  # TODO Make syncthing run as user service, even though settings get written by OS config.
  services.syncthing.enable = false;

  # Start tray as user service
  # services.syncthing.tray = {
  #   # TODO actually use this eventually
  #   # On KDE, it launches the plasmoid automatically (how?)
  #   # On Hyprland, it seems to run in XWayland because it doesn't see the env variables.
  #   enable = false;
  #   command = "syncthingtray --wait";
  #   package = pkgs.syncthingtray;
  # };
  # Perfectly sufficient for plasmoid:
  home.packages = [pkgs.syncthingtray];

  home.activation.configure-syncthingtray = let
    template-config = pkgs.writeText "template-syncthingtray.ini" (lib.generators.toINI {} {
      startup = {
        considerForReconnect = "true";
        considerLauncherForReconnect = "false";
        showButton = "true";
        stopOnMetered = "false";
        stopServiceOnMetered = "false";
        syncthingAutostart = "false";
        syncthingUnit = "syncthing.service";
        systemUnit = "true";
        useLibSyncthing = "false";
      };
      tray = {
        "connections\\1\\label" = "local";
        "connections\\1\\authEnabled" = "true";
        "connections\\1\\autoConnect" = "true";
        "connections\\1\\syncthingUrl" = "http://127.0.0.1:8384";
        "connections\\1\\apiKey" = "@ByteArray(SYNCTHING_APIKEY_LOCAL)";
        "connections\\2\\label" = "nasman";
        "connections\\2\\authEnabled" = "true";
        "connections\\2\\autoConnect" = "true";
        "connections\\2\\syncthingUrl" = "https://syncit.hepr.me:443";
        "connections\\2\\apiKey" = "@ByteArray(SYNCTHING_APIKEY_NASMAN)";
        "connections\\size" = "2";
        notifyOnDisconnect = "true";
        notifyOnErrors = "true";
        notifyOnLauncherErrors = "true";
        notifyOnLocalSyncComplete = "false";
        notifyOnNewDeviceConnects = "true";
        notifyOnNewDirectoryShared = "true";
        notifyOnRemoteSyncComplete = "false";
        preferIconsFromTheme = "true";
        showSyncthingNotifications = "true";
        showTabTexts = "true";
        showTraffic = "true";
        statusIcons = "#ff26b6db,#ff0882c8,#ffffffff;#ffdb3c26,#ffc80828,#ffffffff;#ffc9ce3b,#ffebb83b,#ffffffff;#ff0e9d5a,#ff0e9d5a,#ffffffff;#ff26b6db,#ff0882c8,#ffffffff;#ff26b6db,#ff0882c8,#ffffffff;#ffa9a9a9,#ff58656c,#ffffffff;#ffa9a9a9,#ff58656c,#ffffffff";
        trayIcons = "#ff26b6db,#ff0882c8,#ffffffff;#ffdb3c26,#ffc80828,#ffffffff;#ffc9ce3b,#ffebb83b,#ffffffff;#ff0e9d5a,#ff0e9d5a,#ffffffff;#ff26b6db,#ff0882c8,#ffffffff;#ff26b6db,#ff0882c8,#ffffffff;#ffa9a9a9,#ff58656c,#ffffffff;#ffa9a9a9,#ff58656c,#ffffffff";
      };
      webview.disabled = "true";
    });
    config-script =
      pkgs.writers.writeNuBin "configure-syncthingtray" {
        makeWrapperArgs = [
          "--prefix"
          "PATH"
          ":"
          "${lib.makeBinPath [pkgs.gnused pkgs.syncthingtray]}"
        ];
      } ''
        def main [pathToConfigTemplate: string] {
          let SYNCTHING_APIKEY_LOCAL = syncthingctl cat | from json | get gui.apiKey
          let SYNCTHING_APIKEY_NASMAN = open --raw /run/agenix/syncthing-api-key-nasman | str trim
          let configTemplate = open --raw $pathToConfigTemplate
          let finalConfig = (
            $configTemplate
          | sed $"s#SYNCTHING_APIKEY_LOCAL#($SYNCTHING_APIKEY_LOCAL)#"
          | sed $"s#SYNCTHING_APIKEY_NASMAN#($SYNCTHING_APIKEY_NASMAN)#"
          )

          $finalConfig | save -f "${config.xdg.configHome}/syncthingtray.ini"
        }
      '';
  in
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      run "${lib.getExe config-script}" "${template-config}"
    '';
}
