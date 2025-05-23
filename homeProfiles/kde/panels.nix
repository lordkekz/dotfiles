# My panel layout for KDE Plasma
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
  programs.plasma.panels = [
    # Taskbar / Launcher at the Bottom
    {
      height = 48;
      offset = 0;
      minLength = 720;
      maxLength = 2400;
      location = "bottom";
      alignment = "center";
      hiding = "autohide";
      floating = false;

      widgets = [
        # Start menu
        {
          name = "org.kde.plasma.kickoff";
          config = {
            General.icon = "nix-snowflake";
          };
        }
        # Taskbar window icons
        {
          name = "org.kde.plasma.icontasks";
          config = {
            General.launchers = [
              # Pinned apps
              "applications:org.kde.dolphin.desktop"
              "applications:firefox.desktop"
              "applications:foot.desktop"
              #"applications:Alacritty.desktop"
              "applications:obsidian.desktop"
            ];
          };
        }
      ];
    }
    # Global menu at the top
    {
      height = 32;
      offset = 0;
      minLength = null;
      maxLength = null; # Allow it to grow to screen width
      location = "top";
      alignment = "center";
      hiding = "none";
      floating = false;

      widgets = [
        "org.kde.plasma.appmenu"
        #{
        #  name = "org.kde.plasma.panelspacer";
        #  config = {
        #    General.expanding = "false";
        #    General.length = "5";
        #  };
        #}
        "org.kde.plasma.panelspacer"
        #{
        #  name = "org.kde.plasma.betterinlineclock";
        #  config.Appearance = {
        #    dateFormat = "isoDate";
        #    fixedFont = "true";
        #    fontSize = "14";
        #    showSeconds = "true";
        #  };
        #}
        {
          name = "org.kde.plasma.digitalclock";
          config.Appearance = {
            dateDisplayFormat = "BesideTime";
            dateFormat = "isoDate";
            showSeconds = "true";
          };
        }
        "org.kde.plasma.panelspacer"
        "martchus.syncthingplasmoid"
        "org.kde.plasma.systemtray"
      ];
    }
  ];
}
