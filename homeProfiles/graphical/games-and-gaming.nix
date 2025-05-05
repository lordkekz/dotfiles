# Games and gaming configuration
args @ {
  inputs,
  outputs,
  homeProfiles,
  personal-data,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  system,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    prismlauncher
    heroic
    gamescope
    #steam # steam gets enabled in NixOSConfig
    wineWowPackages.stable # support both 32- and 64-bit applications
    #linux-wallpaperengine # Wallpaper Engine
    superTux
    superTuxKart
    extremetuxracer
    shattered-pixel-dungeon

    # LUDUSAVI, a game save manager supporting Steam and Heroic
    # TODO: Consider ludusavi's native rclone-based cloud backups
    # https://github.com/mtkennerly/ludusavi/blob/master/docs/help/cloud-backup.md
    ludusavi
    (pkgs.writeShellApplication {
      # REQUIRES: manual setup in Heroic; set "wrapper command"
      # in Game defaults and for all already installed games.
      # See: https://github.com/mtkennerly/ludusavi/blob/cef02676fab5b8567cdb4e35f3f1f925dfdf71c9/docs/help/game-launch-wrapping.md#heroic
      name = "ludusavi-wrapper-heroic";
      text = ''
        ludusavi --config "$HOME/.config/ludusavi" wrap --gui --infer heroic -- "$@"
      '';
    })
  ];

  xdg.desktopEntries."Dungeondraft" = {
    name = "Dungeondraft";
    comment = "Dungeondraft is a tabletop encounter map creation tool designed to draw aesthetic maps without the typical frustrations and time investment.";
    exec = "${lib.getExe pkgs.steam-run} ${config.home.homeDirectory}/Documents/Backup/Spielstände/Dungeondraft/latest/Dungeondraft.x86_64";
    settings.Path = "${config.home.homeDirectory}/Documents/Backup/Spielstände/Dungeondraft/latest/";
    icon = "${config.home.homeDirectory}/Documents/Backup/Spielstände/Dungeondraft/latest/Dungeondraft.png";
    categories = ["Graphics"];
  };
}
