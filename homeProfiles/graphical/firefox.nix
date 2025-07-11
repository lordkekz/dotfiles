# Configure firefox.
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
  # The main nixpkgs channel; searches will be for this version
  channel = pkgs.lib.trivial.release;

  # The NixOS module applies some config to the package.
  # We just use that final package to avoid potential conflicts.
  package =
    if args ? osConfig
    then args.osConfig.programs.firefox.finalPackage
    else pkgs.firefox;

  settings-default = {
    "signon.rememberSignons" = false;
    "browser.aboutConfig.showWarning" = false;
    "browser.compactmode.show" = true;

    # Restore previous session
    "browser.startup.page" = 3;

    # Disable caching requests to disk; enable and expand in-memory caching.
    "browser.cache.memory.enable" = true;
    "browser.cache.memory.capacity" = -1; # Unlimited
    "browser.cache.memory.max_entry_size" = 51200;
    "browser.cache.disk.enable" = false;

    # Nerf mouse scroll speed
    "mousewheel.default.delta_multiplier_x" = 75; # Default was 100
    "mousewheel.default.delta_multiplier_y" = 75; # Default was 100
    "mousewheel.default.delta_multiplier_z" = 75; # Default was 100
    "general.smoothScroll" = true;

    # Force showing the system titlebar decoration
    "browser.tabs.inTitlebar" = 0;

    # Define ui layout
    "browser.uiCustomization.horizontalTabstrip" = "[]";
    "browser.uiCustomization.state" = builtins.readFile ./firefox-uiCustomization.json;

    # Configure revamped sidebar and vertical tabs
    "sidebar.revamp" = true;
    "sidebar.verticalTabs" = true;
    "sidebar.visibility" = "always-show";
    "sidebar.animation.enabled" = true;
    "sidebar.animation.duration-ms" = 200;

    # Disable annoying titlebar results
    "browser.urlbar.suggest.history" = false;
    "browser.urlbar.suggest.topsites" = false;
  };
  search = rec {
    force = true;
    default = "MyDuckDuckGo";
    privateDefault = default;
    order = ["MyDuckDuckGo" "google" "MyNixOS" "NixOS Wiki" "Nix Packages" "Nix Options" "Noogle Functions" "LEO Ita-Deu"];
    engines = {
      "MyDuckDuckGo" = {
        urls = [{template = "https://duckduckgo.com/?kae=t&k9=48f1ef&kaa=844ad2&kx=25ac86&kak=-1&kax=-1&kaq=-1&kap=-1&kao=-1&kav=1&t=ffab&q={searchTerms}";}];
        icon = "https://duckduckgo.com/favicon.png";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = ["@ddg" "@duckduckgo"];
      };

      "wikipedia".metaData.hidden = true;
      "amazon".metaData.hidden = true;
      "bing".metaData.hidden = true;
      "duckduckgo".metaData.hidden = true;
      "google".metaData.hidden = true;
      "ebay".metaData.hidden = true;

      "Nix Packages" = {
        urls = [{template = "https://search.nixos.org/packages?channel=${channel}&query={searchTerms}";}];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@np" "@nixpackages"];
      };
      "NixOS Options" = {
        urls = [{template = "https://search.nixos.org/options?channel=${channel}&query={searchTerms}";}];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@nc" "@nixconfig"];
      };
      "Nix Flakes" = {
        urls = [{template = "https://search.nixos.org/flakes:q!
        ?channel=${channel}&query={searchTerms}";}];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@nc" "@nixconfig"];
      };
      "Noogle Functions" = {
        urls = [{template = "http://localhost:8013/q?term={searchTerms}";}];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@no" "@noogle"];
      };
      "NixOS Wiki" = {
        urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@nw" "@nixwiki"];
      };
      "MyNixOS" = {
        urls = [{template = "https://mynixos.com/search?q={searchTerms}";}];
        icon = "https://mynixos.com/favicon.ico";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = ["@nix"];
      };
      "Arch Wiki" = {
        urls = [{template = "https://wiki.archlinux.org/index.php?search={searchTerms}";}];
        icon = "https://archlinux.org/static/logos/apple-touch-icon-144x144.38cf584757c3.png";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = ["@arch"];
      };
      "Google Scholar" = {
        urls = [{template = "https://scholar.google.com/scholar?q={searchTerms}";}];
        icon = "https://scholar.google.com/favicon.ico";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = ["@gs"];
      };
      "LEO Ita-Deu" = {
        urls = [{template = "https://dict.leo.org/tedesco-italiano/{searchTerms}";}];
        icon = "https://dict.leo.org/img/favicons/itde.ico";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = ["@ita"];
      };
    };
  };
in {
  programs.firefox = {
    enable = true;
    inherit package;
    profiles."default" = {
      id = 0;
      isDefault = true;
      settings =
        settings-default
        // {};
      inherit search;
    };
    profiles."homework" = {
      id = 1;
      isDefault = false;
      settings =
        settings-default
        // {};
      inherit search;
    };
  };

  stylix.targets.firefox = {
    profileNames = ["default"];
  };
}
