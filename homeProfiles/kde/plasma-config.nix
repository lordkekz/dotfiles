# My config for KDE Plasma 5
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
  imports = [homeProfiles.graphical];

  programs.plasma = {
    enable = true;
    shortcuts = {
      "ActivityManager"."switch-to-activity-0ea01e9d-4522-405e-ad09-1a5d4e7b3669" = [];
      "kcm_touchpad"."Toggle Touchpad" = ["Meta+Ctrl+Zenkaku Hankaku" "Touchpad Toggle"];
      "kwin"."Invert" = "Meta+Ctrl+I";
      "kwin"."Invert Screen Colors" = [];
      "kwin"."InvertWindow" = "Meta+Ctrl+U";
      "kwin"."Move Tablet to Next Output" = [];
      "kwin"."Toggle" = [];
      "kwin"."ToggleMouseClick" = "Meta+*";
      "kwin"."TrackMouse" = [];
      "org.kde.spectacle.desktop"."RectangularRegionScreenShot" = ["Meta+Shift+Print" "Meta+Shift+S"];
      "org_kde_powerdevil"."Sleep" = ["Launch Media" "Sleep"];
    };
    configFile = {
      "dolphinrc"."DetailsMode"."PreviewSize".value = 16;
      "dolphinrc"."KFileDialog Settings"."detailViewIconSize".value = 16;
      "kactivitymanagerdrc"."activities"."0ea01e9d-4522-405e-ad09-1a5d4e7b3669".value = "Default";
      "kactivitymanagerdrc"."main"."currentActivity".value = "0ea01e9d-4522-405e-ad09-1a5d4e7b3669";
      "kactivitymanagerdrc"."main"."runningActivities".value = "0ea01e9d-4522-405e-ad09-1a5d4e7b3669";
      "kactivitymanagerdrc"."main"."stoppedActivities".value = "";
      "kcminputrc"."Libinput.2362.628.PIXA3854:00 093A:0274 Touchpad"."ClickMethod".value = 2;
      "kcminputrc"."Libinput.2362.628.PIXA3854:00 093A:0274 Touchpad"."NaturalScroll".value = true;
      "kcminputrc"."Libinput.2362.628.PIXA3854:00 093A:0274 Touchpad"."ScrollFactor".value = 0.5;
      "kcminputrc"."Libinput.2362.628.PIXA3854:00 093A:0274 Touchpad"."TapToClick".value = true;
      "kcminputrc"."Mouse"."cursorSize".value = 32;
      "kcminputrc"."Mouse"."cursorTheme".value = "Posy_Cursor_Black";
      "kded5rc"."Module-browserintegrationreminder"."autoload".value = false;
      "kded5rc"."Module-device_automounter"."autoload".value = true;
      "kded5rc"."PlasmaBrowserIntegration"."shownCount".value = 4;
      "kdeglobals"."DesktopGrid"."ShowDesktopGrid".value = "Meta+G";
      "kdeglobals"."DirSelect Dialog"."DirSelectDialog Size".value = "853,598";
      "kdeglobals"."General"."BrowserApplication".value = "firefox.desktop";
      "kdeglobals"."General"."LastUsedCustomAccentColor".value = "0,211,184";
      "kdeglobals"."General"."TerminalApplication".value = "alacritty";
      "kdeglobals"."General"."TerminalService".value = "Alacritty.desktop";
      "kdeglobals"."General"."XftHintStyle".value = "hintslight";
      "kdeglobals"."General"."XftSubPixel".value = "none";
      "kdeglobals"."General"."fixed".value = "JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0";
      "kdeglobals"."KDE"."SingleClick".value = false;
      "kdeglobals"."KFileDialog Settings"."Allow Expansion".value = false;
      "kdeglobals"."KFileDialog Settings"."Automatically select filename extension".value = true;
      "kdeglobals"."KFileDialog Settings"."Breadcrumb Navigation".value = true;
      "kdeglobals"."KFileDialog Settings"."Decoration position".value = 2;
      "kdeglobals"."KFileDialog Settings"."LocationCombo Completionmode".value = 5;
      "kdeglobals"."KFileDialog Settings"."PathCombo Completionmode".value = 5;
      "kdeglobals"."KFileDialog Settings"."Show Bookmarks".value = false;
      "kdeglobals"."KFileDialog Settings"."Show Full Path".value = false;
      "kdeglobals"."KFileDialog Settings"."Show Inline Previews".value = true;
      "kdeglobals"."KFileDialog Settings"."Show Preview".value = false;
      "kdeglobals"."KFileDialog Settings"."Show Speedbar".value = true;
      "kdeglobals"."KFileDialog Settings"."Show hidden files".value = false;
      "kdeglobals"."KFileDialog Settings"."Sort by".value = "Name";
      "kdeglobals"."KFileDialog Settings"."Sort directories first".value = true;
      "kdeglobals"."KFileDialog Settings"."Sort hidden files last".value = false;
      "kdeglobals"."KFileDialog Settings"."Sort reversed".value = false;
      "kdeglobals"."KFileDialog Settings"."Speedbar Width".value = 138;
      "kdeglobals"."KFileDialog Settings"."View Style".value = "DetailTree";
      "kdeglobals"."KScreen"."ScaleFactor".value = 1.5;
      "kdeglobals"."KScreen"."ScreenScaleFactors".value = "eDP-1=1.5;";
      "kdeglobals"."KShortcutsDialog Settings"."Dialog Size".value = "600,480";
      "kdeglobals"."WM"."activeBackground".value = "44,55,70";
      "kdeglobals"."WM"."activeBlend".value = "44,55,70";
      "kdeglobals"."WM"."activeForeground".value = "255,255,255";
      "kdeglobals"."WM"."inactiveBackground".value = "44,55,70";
      "kdeglobals"."WM"."inactiveBlend".value = "44,55,70";
      "kdeglobals"."WM"."inactiveForeground".value = "181,182,182";
      "khotkeysrc"."Data_2_1Triggers0"."Uuid".value = "{69d86897-6a45-426a-972c-7b61cdb7560a}";
      "khotkeysrc"."Data_2_2Triggers0"."Uuid".value = "{4fb64b75-a7c5-4e7d-a273-3baab193db1a}";
      "khotkeysrc"."Data_2_3Triggers0"."Uuid".value = "{e12eb911-3bde-49ca-afbc-de740902a774}";
      "khotkeysrc"."Data_2_4Triggers0"."Uuid".value = "{2bc69be2-5ea5-4229-b555-fa4d67f235ae}";
      "khotkeysrc"."Data_2_5Triggers0"."Uuid".value = "{0bc81494-82e4-41d5-bda7-ed3399d14c30}";
      "khotkeysrc"."Data_2_6Triggers0"."Uuid".value = "{b035ad5b-54ee-4b25-9885-5b18fded0824}";
      "khotkeysrc"."Data_2_8Triggers0"."Uuid".value = "{804dfe25-d16d-48f1-8db5-050668d10c47}";
      "khotkeysrc"."DesktopGrid"."ShowDesktopGrid[$d]".value = "";
      "khotkeysrc"."DirSelect Dialog"."DirSelectDialog Size[$d]".value = "";
      "khotkeysrc"."General"."BrowserApplication[$d]".value = "";
      "khotkeysrc"."General"."LastUsedCustomAccentColor[$d]".value = "";
      "khotkeysrc"."General"."TerminalApplication[$d]".value = "";
      "khotkeysrc"."General"."TerminalService[$d]".value = "";
      "khotkeysrc"."General"."XftHintStyle[$d]".value = "";
      "khotkeysrc"."General"."XftSubPixel[$d]".value = "";
      "khotkeysrc"."General"."fixed[$d]".value = "";
      "khotkeysrc"."KDE"."LookAndFeelPackage[$d]".value = "";
      "khotkeysrc"."KDE"."SingleClick[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Allow Expansion[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Automatically select filename extension[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Breadcrumb Navigation[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Decoration position[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."LocationCombo Completionmode[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."PathCombo Completionmode[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Show Bookmarks[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Show Full Path[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Show Inline Previews[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Show Preview[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Show Speedbar[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Show hidden files[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Sort by[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Sort directories first[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Sort hidden files last[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Sort reversed[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."Speedbar Width[$d]".value = "";
      "khotkeysrc"."KFileDialog Settings"."View Style[$d]".value = "";
      "khotkeysrc"."KScreen"."ScaleFactor[$d]".value = "";
      "khotkeysrc"."KScreen"."ScreenScaleFactors[$d]".value = "";
      "khotkeysrc"."KScreen"."XwaylandClientsScale[$d]".value = "";
      "khotkeysrc"."KShortcutsDialog Settings"."Dialog Size[$d]".value = "";
      "ksmserverrc"."SubSession: 2052f117-46b2-4cc6-bbb7-cdd9fbc6b471"."count".value = 0;
      "kwalletrc"."Auto Allow"."kdewallet".value = "kded5";
      "kwalletrc"."Auto Deny"."kdewallet".value = "";
      "kwalletrc"."Wallet"."Close When Idle".value = false;
      "kwalletrc"."Wallet"."Close on Screensaver".value = false;
      "kwalletrc"."Wallet"."Default Wallet".value = "kdewallet";
      "kwalletrc"."Wallet"."Enabled".value = true;
      "kwalletrc"."Wallet"."First Use".value = false;
      "kwalletrc"."Wallet"."Idle Timeout".value = 10;
      "kwalletrc"."Wallet"."Launch Manager".value = false;
      "kwalletrc"."Wallet"."Leave Manager Open".value = false;
      "kwalletrc"."Wallet"."Leave Open".value = true;
      "kwalletrc"."Wallet"."Prompt on Open".value = false;
      "kwalletrc"."Wallet"."Use One Wallet".value = true;
      "kwalletrc"."org.freedesktop.secrets"."apiEnabled".value = true;
      "kwinrc"."Desktops"."Id_1".value = "96ba0670-ca8c-46b3-8cf7-163e7bf2024e";
      "kwinrc"."Effect-desktopgrid"."BorderActivate".value = 7;
      "kwinrc"."Effect-glide"."Duration".value = 150;
      "kwinrc"."Effect-glide"."InDistance".value = 60;
      "kwinrc"."Effect-glide"."InRotationAngle".value = 6;
      "kwinrc"."Effect-glide"."OutDistance".value = 60;
      "kwinrc"."Effect-glide"."OutRotationAngle".value = 6;
      "kwinrc"."Effect-windowview"."BorderActivateAll".value = 9;
      "kwinrc"."Effect-windowview"."LayoutMode".value = 0;
      "kwinrc"."NightColor"."Active".value = true;
      "kwinrc"."NightColor"."EveningBeginFixed".value = 2200;
      "kwinrc"."NightColor"."LatitudeAuto".value = 51.4825;
      "kwinrc"."NightColor"."LongitudeAuto".value = 11.9772;
      "kwinrc"."NightColor"."Mode".value = "Times";
      "kwinrc"."Plugins"."desktopchangeosdEnabled".value = true;
      "kwinrc"."Plugins"."glideEnabled".value = true;
      "kwinrc"."Plugins"."kwin4_effect_dimscreenEnabled".value = true;
      "kwinrc"."Plugins"."kwin4_effect_scaleEnabled".value = false;
      "kwinrc"."Plugins"."kwin4_effect_translucencyEnabled".value = true;
      "kwinrc"."Plugins"."trackmouseEnabled".value = true;
      "kwinrc"."SubSession: 2052f117-46b2-4cc6-bbb7-cdd9fbc6b471"."active".value = "-1";
      "kwinrc"."SubSession: 2052f117-46b2-4cc6-bbb7-cdd9fbc6b471"."count".value = 0;
      "kwinrc"."Tiling"."padding".value = 4;
      "kwinrc"."Tiling.037f2fbe-1551-5d01-ba53-36da9c08c968"."tiles".value = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.213a9620-187e-58a6-b80b-85d8fb95dfce"."tiles".value = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.3c373409-48e0-57e9-a1a9-eb32e49f8772"."tiles".value = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.5f997858-bd2c-529b-8e36-04d038038924"."tiles".value = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Xwayland"."Scale".value = 1.2;
      "plasma-localerc"."Formats"."LANG".value = "de_DE.UTF-8";
      "systemsettingsrc"."KFileDialog Settings"."detailViewIconSize".value = 16;
    };
  };
}
