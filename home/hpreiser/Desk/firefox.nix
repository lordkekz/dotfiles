# Configure firefox.
args @ {
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  # extraSpecialArgs:
  system,
  username,
  ...
}: let
  settings-default = {
    # "browser.startup.homepage" = "https://duckduckgo.com";
    "browser.search.defaultenginename" = "DuckDuckGo";
    "browser.search.order.1" = "DuckDuckGo";

    "signon.rememberSignons" = false;
    "browser.aboutConfig.showWarning" = false;
    "browser.compactmode.show" = true;

    # Disable caching requests to disk; enable and expand in-memory caching.
    "browser.cache.memory.enable" = false;
    "browser.cache.memory.capacity" = -1; # Unlimited
    "browser.cache.memory.max_entry_size" = 51200;
    "browser.cache.disk.enable" = false;

    # Nerf mouse scroll speed
    "mousewheel.default.delta_multiplier_x" = 75; # Default was 100
    "mousewheel.default.delta_multiplier_y" = 75; # Default was 100
    "mousewheel.default.delta_multiplier_z" = 75; # Default was 100
    "general.smootScroll" = true;

    # Force showing the system titlebar decoration
    "browser.tabs.inTitlebar" = false;

    # Disable annoying titlebar results
    "browser.urlbar.suggest.history" = false;
    "browser.urlbar.suggest.topsites" = false;
  };
  search = rec {
    force = true;
    default = "MyDuckDuckGo";
    privateDefault = default;
    order = ["MyDuckDuckGo" "Google" "MyNixOS" "NixOS Wiki" "Nix Packages" "Nix Options"];
    engines = {
      "MyDuckDuckGo" = {
        urls = [{template = "https://duckduckgo.com/?kae=t&k9=48f1ef&kaa=844ad2&kx=25ac86&kak=-1&kax=-1&kaq=-1&kap=-1&kao=-1&kav=1&t=ffab&q={searchTerms}";}];
        iconUpdateURL = "https://duckduckgo.com/favicon.png";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = ["@ddg" "@duckduckgo"];
      };

      "Wikipedia (en)".metaData.hidden = true;
      "Amazon.de".metaData.hidden = true;
      "Bing".metaData.hidden = true;
      "DuckDuckGo".metaData.hidden = true;
      "Google".metaData.hidden = true;

      "Nix Packages" = {
        urls = [{template = "https://search.nixos.org/packages?type=packages&query={searchTerms}";}];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@np"];
      };
      "NixOS Options" = {
        urls = [{template = "https://search.nixos.org/packages?type=packages&query={searchTerms}";}];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@no"];
      };
      "NixOS Wiki" = {
        urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = ["@nw" "@nixwiki"];
      };
      "MyNixOS" = {
        urls = [{template = "https://mynixos.com/search?q={searchTerms}";}];
        iconUpdateURL = "https://mynixos.com/favicon.ico";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = ["@nix"];
      };
    };
  };
in {
  programs.firefox = {
    enable = true;
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
}
