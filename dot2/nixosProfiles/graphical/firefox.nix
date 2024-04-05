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
        "enhancerforyoutube@maximerf.addons.mozilla.org" = mkExt "enhancer-for-youtube";
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
        "browser.firefox-view.feature-tour" = lock-value ''{"message":"FIREFOX_VIEW_FEATURE_TOUR","screen":"","complete":true}'';

        "dom.security.https_only_mode" = lock-true;
        "widget.use-xdg-desktop-portal.file-picker" = lock-value 1;

        "browser.uiCustomization.state" = lock-value ''{"placements":{"widget-overflow-fixed-list":["characterencoding-button"],"unified-extensions-area":["sponsorblocker_ajay_app-browser-action","dearrow_ajay_app-browser-action","jid1-mnnxcxisbpnsxq_jetpack-browser-action","_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action","_531906d3-e22f-4a6c-a102-8057b88a1a63_-browser-action","_580efa7d-66f9-474d-857a-8e2afc6b1181_-browser-action","_c5f935cf-9b17-4b85-bed8-9277861b4116_-browser-action","_b9db16a4-6edc-47ec-a1f4-b86292ed211d_-browser-action","enhancerforyoutube_maximerf_addons_mozilla_org-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","urlbar-container","bookmarks-menu-button","downloads-button","history-panelmenu","jetpack-extension_dashlane_com-browser-action","ublock0_raymondhill_net-browser-action","umatrix_raymondhill_net-browser-action","_dccd64f0-f884-496c-af8b-1a66330e1a67_-browser-action","extension_one-tab_com-browser-action","unified-extensions-button","plasma-browser-integration_kde_org-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button","firefox-view-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","jetpack-extension_dashlane_com-browser-action","_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action","extension_one-tab_com-browser-action","ublock0_raymondhill_net-browser-action","dearrow_ajay_app-browser-action","_531906d3-e22f-4a6c-a102-8057b88a1a63_-browser-action","_580efa7d-66f9-474d-857a-8e2afc6b1181_-browser-action","_c5f935cf-9b17-4b85-bed8-9277861b4116_-browser-action","umatrix_raymondhill_net-browser-action","sponsorblocker_ajay_app-browser-action","jid1-mnnxcxisbpnsxq_jetpack-browser-action","_dccd64f0-f884-496c-af8b-1a66330e1a67_-browser-action","_b9db16a4-6edc-47ec-a1f4-b86292ed211d_-browser-action","plasma-browser-integration_kde_org-browser-action","enhancerforyoutube_maximerf_addons_mozilla_org-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","unified-extensions-area","widget-overflow-fixed-list"],"currentVersion":20,"newElementCount":4}'';
        "layout.css.prefers-color-scheme.content-override" = lock-value 0; # Set website appearance to dark mode.
      };
    };
  };
}
