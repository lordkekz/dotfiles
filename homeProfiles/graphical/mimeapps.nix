# Define some MIME associations
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
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = let
    thunderbird = [
      "com.ulduzsoft.Birdtray.desktop"
      "thunderbird.desktop"
    ];
    codium = ["codium.desktop"];
    codiumURL = ["codium-url-handler.desktop"] ++ codium;
    ark = ["org.kde.ark.desktop"];
    dolphin = ["org.kde.dolphin.desktop"];
    yazi = ["yazi.desktop"];
    nvim = ["nvim.desktop"];
    firefox = ["firefox.desktop"];
    jetbrains-toolbox = ["jetbrains-toolbox.desktop"];
    signal = ["signal-desktop.desktop"];
    telegram = ["org.telegram.desktop.desktop"];
    okular = ["org.kde.okular.desktop"];
    gwenview = ["org.kde.gwenview.desktop"];
    gimp = ["gimp.desktop"];
    zathura = ["org.pwmt.zathura.desktop"];
  in {
    "application/rss+xml" = thunderbird;
    "application/x-desktop" = codium;
    "application/x-extension-ics" = thunderbird;
    "application/x-extension-rss" = thunderbird;
    "application/zip" = ark;
    "application/pdf" = zathura ++ okular;
    "application/epub+zip" = zathura ++ okular;
    "inode/directory" = dolphin ++ yazi;
    "message/rfc822" = thunderbird;
    "text/calendar" = thunderbird;
    "text/plain" = codium ++ nvim;
    "x-scheme-handler/feed" = thunderbird;
    "x-scheme-handler/http" = firefox;
    "x-scheme-handler/https" = firefox;
    "x-scheme-handler/jetbrains" = jetbrains-toolbox;
    "x-scheme-handler/vscode" = codiumURL;
    "x-scheme-handler/mailto" = thunderbird;
    "x-scheme-handler/mid" = thunderbird;
    "x-scheme-handler/news" = thunderbird;
    "x-scheme-handler/nntp" = thunderbird;
    "x-scheme-handler/sgnl" = signal;
    "x-scheme-handler/signalcaptcha" = signal;
    "x-scheme-handler/snews" = thunderbird;
    "x-scheme-handler/tg" = telegram;
    "x-scheme-handler/webcal" = thunderbird;
    "x-scheme-handler/webcals" = thunderbird;
    "image/avif" = gwenview;
    "image/gif" = gwenview;
    "image/heif" = gwenview;
    "image/jpeg" = gwenview;
    "image/png" = gwenview;
    "image/bmp" = gwenview;
    "image/x-eps" = gwenview;
    "image/x-icns" = gwenview;
    "image/x-ico" = gwenview;
    "image/x-portable-bitmap" = gwenview;
    "image/x-xbitmap" = gwenview;
    "image/x-xpixmap" = gwenview;
    "image/tiff" = gwenview;
    "image/x-psd" = gwenview;
    "image/x-webp" = gwenview;
    "image/webp" = gwenview;
    "image/x-xcf" = gimp ++ gwenview;
  };
}
