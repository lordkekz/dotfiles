# Firefox config, addons, theming and ui-customization.
{
  inputs,
  outputs,
  nixosProfiles,
  lib,
  config,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  ...
}: let
  lock-false = lock-value false;
  lock-true = lock-value true;
  lock-value = Value: {
    inherit Value;
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
      DontCheckDefaultBrowser = true; # For some reason this fucks up with my impermanence setup
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

        # Privacy
        "uBlock0@raymondhill.net" = mkExt "ublock-origin";
        "uMatrix@raymondhill.net" = mkExt "umatrix";
        "jid1-MnnxcxisBPnSXQ@jetpack" = mkExt "privacy-badger17";
        "{b86e4813-687a-43e6-ab65-0bde4ab75758}" = mkExt "localcdn-fork-of-decentraleyes";

        # Youtube
        "enhancerforyoutube@maximerf.addons.mozilla.org" = mkExt "enhancer-for-youtube";
        "{dccd64f0-f884-496c-af8b-1a66330e1a67}" = mkExt "youtube-audio_only";
        "{b9db16a4-6edc-47ec-a1f4-b86292ed211d}" = mkExt "video-downloadhelper";
        "sponsorBlocker@ajay.app" = mkExt "sponsorblock";
        "deArrow@ajay.app" = mkExt "dearrow";

        # Productivity & Features
        "{531906d3-e22f-4a6c-a102-8057b88a1a63}" = mkExt "single-file";
        "extension@one-tab.com" = mkExt "onetab";
        #"treestyletab@piro.sakura.ne.jp" = mkExt "tree-style-tab";
        "jetpack-extension@dashlane.com" = mkExt "dashlane";
        "addon@darkreader.org" = mkExt "darkreader"; # Can also style titlebar black
        "FirefoxColor@mozilla.com" = mkExt "firefox-color";

        # Plasma integration
        "plasma-browser-integration@kde.org" = mkExt "plasma-integration";

        # Zotero integration
        "zotero@chnm.gmu.edu" = {
          install_url = "https://www.zotero.org/download/connector/dl?browser=firefox";
          installation_mode = "force_installed";
        };
      };

      /*
      ---- PREFERENCES ----
      */
      # Check about:config for options.
      Preferences = {
        "browser.contentblocking.category" = lock-value "strict";
        "extensions.pocket.enabled" = lock-false;
        "extensions.screenshots.disabled" = lock-false; # TODO decide on this
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
        "browser.firefox-view.feature-tour" = lock-value ''{"message":"FIREFOX_VIEW_FEATURE_TOUR","screen":"","complete":true}'';
        # Always new tab for popup windows
        "browser.link.open_newwindow" = lock-value 3;
        "browser.link.open_newwindow.restriction" = lock-value 0;

        "dom.security.https_only_mode" = lock-true;
        "widget.use-xdg-desktop-portal.file-picker" = lock-value 1;

        # Set website appearance to match browser's polarity.
        "layout.css.prefers-color-scheme.content-override" = lock-value 3;
      };
    };
  };
}
