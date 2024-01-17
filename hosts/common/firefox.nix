# Some firefox defaults.
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
  lock-empty-string = {
    Value = "";
    Status = "locked";
  };
  mkExt = addon-name: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${addon-name}/latest.xpi";
    installation_mode = "force_installed";
  };
in {
  programs.firefox = {
    enable = true;
    languagePacks = ["de" "en-US"];

    /*
    ---- POLICIES ----
    */
    # Check about:policies#documentation for options.
    policies = {
      DisableTelemetry = false;
      DisableFirefoxStudies = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccounts = false;
      DisableAccounts = false;
      DisableFirefoxScreenshots = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = false;
      DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
      DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
      SearchBar = "unified"; # alternative: "separate"

      /*
      ---- EXTENSIONS ----
      */
      # Check about:support for extension/add-on ID strings.
      # Valid strings for installation_mode are "allowed", "blocked",
      # "force_installed" and "normal_installed".
      ExtensionSettings = {
        "*".installation_mode = "blocked"; # blocks all addons except the ones specified below

        # A Catpuccin theme
        "{87adc190-0881-4325-8f33-166782c657e0}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4176958/catppuccin_muave_frappe-1.0.xpi";
          installation_mode = "force_installed";
        };

        # Privacy
        "uBlock0@raymondhill.net" = mkExt "ublock-origin";
        "uMatrix@raymondhill.net" = mkExt "umatrix";
        "jid1-MnnxcxisBPnSXQ@jetpack" = mkExt "privacy-badger17";
        "{b86e4813-687a-43e6-ab65-0bde4ab75758}" = mkExt "localcdn-fork-of-decentraleyes";

        # Youtube
        "{dccd64f0-f884-496c-af8b-1a66330e1a67}" = mkExt "youtube-audio_only";
        "{b9db16a4-6edc-47ec-a1f4-b86292ed211d}" = mkExt "video-downloadhelper";
        "sponsorBlocker@ajay.app" = mkExt "sponsorblock";
        "deArrow@ajay.app" = mkExt "dearrow";

        # Productivity & Features
        "{531906d3-e22f-4a6c-a102-8057b88a1a63}" = mkExt "single-file";
        "extension@one-tab.com" = mkExt "onetab";
        "jetpack-extension@dashlane.com" = mkExt "dashlane";

        # Plasma integration is broken as of 2024-01-10.
        #"plasma-browser-integration@kde.org" = mkExt "plasma-integration";
      };

      /*
      ---- PREFERENCES ----
      */
      # Check about:config for options.
      Preferences = {
        "browser.contentblocking.category" = {
          Value = "strict";
          Status = "locked";
        };
        "extensions.pocket.enabled" = lock-false;
        "extensions.screenshots.disabled" = lock-true;
        "browser.topsites.contile.enabled" = lock-false;
        "browser.formfill.enable" = lock-false;
        "browser.search.suggest.enabled" = lock-false;
        "browser.search.suggest.enabled.private" = lock-false;
        "browser.urlbar.suggest.searches" = lock-false;
        "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-true;
        "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
        "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
        "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
        "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
        "browser.newtabpage.activity-stream.showSponsored" = lock-false;
        "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
        "browser.download.autohideButton" = lock-false;
        "browser.firefox-view.feature-tour" = {
          Value = ''{"message":"FIREFOX_VIEW_FEATURE_TOUR","screen":"","complete":true}'';
          Status = "default";
        };
        "dom.security.https_only_mode" = lock-true;
        "widget.use-xdg-desktop-portal.file-picker" = {
          Value = 1;
          Status = "lock";
        };
      };
    };
  };
}
