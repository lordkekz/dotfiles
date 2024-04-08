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
      "dolphinrc"."DetailsMode"."PreviewSize" = 16;
      "dolphinrc"."KFileDialog Settings"."detailViewIconSize" = 16;
      "kactivitymanagerdrc"."activities"."0ea01e9d-4522-405e-ad09-1a5d4e7b3669" = "Default";
      "kactivitymanagerdrc"."main"."currentActivity" = "0ea01e9d-4522-405e-ad09-1a5d4e7b3669";
      "kactivitymanagerdrc"."main"."runningActivities" = "0ea01e9d-4522-405e-ad09-1a5d4e7b3669";
      "kactivitymanagerdrc"."main"."stoppedActivities" = "";
      "kcminputrc"."Libinput.2362.628.PIXA3854:00 093A:0274 Touchpad"."ClickMethod" = 2;
      "kcminputrc"."Libinput.2362.628.PIXA3854:00 093A:0274 Touchpad"."NaturalScroll" = true;
      "kcminputrc"."Libinput.2362.628.PIXA3854:00 093A:0274 Touchpad"."ScrollFactor" = 0.5;
      "kcminputrc"."Libinput.2362.628.PIXA3854:00 093A:0274 Touchpad"."TapToClick" = true;
      "kcminputrc"."Mouse"."cursorSize" = 32;
      "kcminputrc"."Mouse"."cursorTheme" = "Posy_Cursor_Black";
      "kded5rc"."Module-browserintegrationreminder"."autoload" = false;
      "kded5rc"."Module-device_automounter"."autoload" = true;
      "kded5rc"."PlasmaBrowserIntegration"."shownCount" = 4;
      "kdeglobals"."DesktopGrid"."ShowDesktopGrid" = "Meta+G";
      "kdeglobals"."DirSelect Dialog"."DirSelectDialog Size" = "853,598";
      "kdeglobals"."General"."BrowserApplication" = "firefox.desktop";
      "kdeglobals"."General"."LastUsedCustomAccentColor" = "0,211,184";
      "kdeglobals"."General"."TerminalApplication" = "alacritty";
      "kdeglobals"."General"."TerminalService" = "Alacritty.desktop";
      "kdeglobals"."General"."XftHintStyle" = "hintslight";
      "kdeglobals"."General"."XftSubPixel" = "none";
      "kdeglobals"."General"."fixed" = "JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0";
      "kdeglobals"."KDE"."SingleClick" = false;
      "kdeglobals"."KFileDialog Settings"."Allow Expansion" = false;
      "kdeglobals"."KFileDialog Settings"."Automatically select filename extension" = true;
      "kdeglobals"."KFileDialog Settings"."Breadcrumb Navigation" = true;
      "kdeglobals"."KFileDialog Settings"."Decoration position" = 2;
      "kdeglobals"."KFileDialog Settings"."LocationCombo Completionmode" = 5;
      "kdeglobals"."KFileDialog Settings"."PathCombo Completionmode" = 5;
      "kdeglobals"."KFileDialog Settings"."Show Bookmarks" = false;
      "kdeglobals"."KFileDialog Settings"."Show Full Path" = false;
      "kdeglobals"."KFileDialog Settings"."Show Inline Previews" = true;
      "kdeglobals"."KFileDialog Settings"."Show Preview" = false;
      "kdeglobals"."KFileDialog Settings"."Show Speedbar" = true;
      "kdeglobals"."KFileDialog Settings"."Show hidden files" = false;
      "kdeglobals"."KFileDialog Settings"."Sort by" = "Name";
      "kdeglobals"."KFileDialog Settings"."Sort directories first" = true;
      "kdeglobals"."KFileDialog Settings"."Sort hidden files last" = false;
      "kdeglobals"."KFileDialog Settings"."Sort reversed" = false;
      "kdeglobals"."KFileDialog Settings"."Speedbar Width" = 138;
      "kdeglobals"."KFileDialog Settings"."View Style" = "DetailTree";
      "kdeglobals"."KScreen"."ScaleFactor" = 1.5;
      "kdeglobals"."KScreen"."ScreenScaleFactors" = "eDP-1=1.5;";
      "kdeglobals"."KShortcutsDialog Settings"."Dialog Size" = "600,480";
      "kdeglobals"."WM"."activeBackground" = "44,55,70";
      "kdeglobals"."WM"."activeBlend" = "44,55,70";
      "kdeglobals"."WM"."activeForeground" = "255,255,255";
      "kdeglobals"."WM"."inactiveBackground" = "44,55,70";
      "kdeglobals"."WM"."inactiveBlend" = "44,55,70";
      "kdeglobals"."WM"."inactiveForeground" = "181,182,182";
      "khotkeysrc"."Data_2_1Triggers0"."Uuid" = "{69d86897-6a45-426a-972c-7b61cdb7560a}";
      "khotkeysrc"."Data_2_2Triggers0"."Uuid" = "{4fb64b75-a7c5-4e7d-a273-3baab193db1a}";
      "khotkeysrc"."Data_2_3Triggers0"."Uuid" = "{e12eb911-3bde-49ca-afbc-de740902a774}";
      "khotkeysrc"."Data_2_4Triggers0"."Uuid" = "{2bc69be2-5ea5-4229-b555-fa4d67f235ae}";
      "khotkeysrc"."Data_2_5Triggers0"."Uuid" = "{0bc81494-82e4-41d5-bda7-ed3399d14c30}";
      "khotkeysrc"."Data_2_6Triggers0"."Uuid" = "{b035ad5b-54ee-4b25-9885-5b18fded0824}";
      "khotkeysrc"."Data_2_8Triggers0"."Uuid" = "{804dfe25-d16d-48f1-8db5-050668d10c47}";
      "khotkeysrc"."DesktopGrid"."ShowDesktopGrid[$d]" = "";
      "khotkeysrc"."DirSelect Dialog"."DirSelectDialog Size[$d]" = "";
      "khotkeysrc"."General"."BrowserApplication[$d]" = "";
      "khotkeysrc"."General"."LastUsedCustomAccentColor[$d]" = "";
      "khotkeysrc"."General"."TerminalApplication[$d]" = "";
      "khotkeysrc"."General"."TerminalService[$d]" = "";
      "khotkeysrc"."General"."XftHintStyle[$d]" = "";
      "khotkeysrc"."General"."XftSubPixel[$d]" = "";
      "khotkeysrc"."General"."fixed[$d]" = "";
      "khotkeysrc"."KDE"."LookAndFeelPackage[$d]" = "";
      "khotkeysrc"."KDE"."SingleClick[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Allow Expansion[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Automatically select filename extension[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Breadcrumb Navigation[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Decoration position[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."LocationCombo Completionmode[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."PathCombo Completionmode[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Show Bookmarks[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Show Full Path[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Show Inline Previews[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Show Preview[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Show Speedbar[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Show hidden files[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Sort by[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Sort directories first[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Sort hidden files last[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Sort reversed[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."Speedbar Width[$d]" = "";
      "khotkeysrc"."KFileDialog Settings"."View Style[$d]" = "";
      "khotkeysrc"."KScreen"."ScaleFactor[$d]" = "";
      "khotkeysrc"."KScreen"."ScreenScaleFactors[$d]" = "";
      "khotkeysrc"."KScreen"."XwaylandClientsScale[$d]" = "";
      "khotkeysrc"."KShortcutsDialog Settings"."Dialog Size[$d]" = "";
      "ksmserverrc"."SubSession: 2052f117-46b2-4cc6-bbb7-cdd9fbc6b471"."count" = 0;
      "kwalletrc"."Auto Allow"."kdewallet" = "kded5";
      "kwalletrc"."Auto Deny"."kdewallet" = "";
      "kwalletrc"."Wallet"."Close When Idle" = false;
      "kwalletrc"."Wallet"."Close on Screensaver" = false;
      "kwalletrc"."Wallet"."Default Wallet" = "kdewallet";
      "kwalletrc"."Wallet"."Enabled" = true;
      "kwalletrc"."Wallet"."First Use" = false;
      "kwalletrc"."Wallet"."Idle Timeout" = 10;
      "kwalletrc"."Wallet"."Launch Manager" = false;
      "kwalletrc"."Wallet"."Leave Manager Open" = false;
      "kwalletrc"."Wallet"."Leave Open" = true;
      "kwalletrc"."Wallet"."Prompt on Open" = false;
      "kwalletrc"."Wallet"."Use One Wallet" = true;
      "kwalletrc"."org.freedesktop.secrets"."apiEnabled" = true;
      "kwinrc"."Desktops"."Id_1" = "96ba0670-ca8c-46b3-8cf7-163e7bf2024e";
      "kwinrc"."Effect-desktopgrid"."BorderActivate" = 7;
      "kwinrc"."Effect-glide"."Duration" = 150;
      "kwinrc"."Effect-glide"."InDistance" = 60;
      "kwinrc"."Effect-glide"."InRotationAngle" = 6;
      "kwinrc"."Effect-glide"."OutDistance" = 60;
      "kwinrc"."Effect-glide"."OutRotationAngle" = 6;
      "kwinrc"."Effect-windowview"."BorderActivateAll" = 9;
      "kwinrc"."Effect-windowview"."LayoutMode" = 0;
      "kwinrc"."NightColor"."Active" = true;
      "kwinrc"."NightColor"."EveningBeginFixed" = 2200;
      "kwinrc"."NightColor"."LatitudeAuto" = 51.4825;
      "kwinrc"."NightColor"."LongitudeAuto" = 11.9772;
      "kwinrc"."NightColor"."Mode" = "Times";
      "kwinrc"."Plugins"."desktopchangeosdEnabled" = true;
      "kwinrc"."Plugins"."glideEnabled" = true;
      "kwinrc"."Plugins"."kwin4_effect_dimscreenEnabled" = true;
      "kwinrc"."Plugins"."kwin4_effect_scaleEnabled" = false;
      "kwinrc"."Plugins"."kwin4_effect_translucencyEnabled" = true;
      "kwinrc"."Plugins"."trackmouseEnabled" = true;
      "kwinrc"."SubSession: 2052f117-46b2-4cc6-bbb7-cdd9fbc6b471"."active" = "-1";
      "kwinrc"."SubSession: 2052f117-46b2-4cc6-bbb7-cdd9fbc6b471"."count" = 0;
      "kwinrc"."Tiling"."padding" = 4;
      "kwinrc"."Tiling.037f2fbe-1551-5d01-ba53-36da9c08c968"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.213a9620-187e-58a6-b80b-85d8fb95dfce"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.3c373409-48e0-57e9-a1a9-eb32e49f8772"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.5f997858-bd2c-529b-8e36-04d038038924"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Xwayland"."Scale" = 1.2;
      "plasma-localerc"."Formats"."LANG" = "de_DE.UTF-8";
      "systemsettingsrc"."KFileDialog Settings"."detailViewIconSize" = 16;
    };
  };
}
