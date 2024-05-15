# All my terminal-specific user configuration.
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
  imports = [homeProfiles.common];

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # Fetchers
    neofetch
    hyfetch
    fastfetch

    tmatrix # Epic matrix effect
    du-dust # Disk usage visualizer (kind of like Filelight)

    # Benchmarking
    geekbench
    # disk benchmark
    fio
    # Speedtest by Ookla
    ookla-speedtest
    # S.M.A.R.T. tools; provides smartctl
    smartmontools
    # Interactive explorer for nix derivations and dependencies
    nix-tree
  ];

  # A cat with wings
  programs.bat = {
    enable = true;
    config.style = "full";
    extraPackages = with pkgs.bat-extras; [batman];
  };

  # Carapace provides lots of command completions
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  # Zoxide is a cd command which learns common paths
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    options = [
      "--cmd cd" # Replace built-in cd command with zoxide
    ];
  };

  # File fuzzy finder
  programs.fzf.enable = true;

  # Quick, example-driven man pages powered by tldr-pages
  programs.tealdeer = {
    enable = true;
    settings.updates = {
      # Automatically update the cache.
      # Also useful if cache gets deleted; otherwise needs to be fixed manually.
      auto_update = true;
      auto_update_interval_hours = 24 * 7;
    };
  };

  # Atuin shell history
  programs.atuin = {
    enable = true;
    enableNushellIntegration = true;
    package = pkgs-unstable.atuin;
    settings = {
      # See https://docs.atuin.sh/configuration/config
      search_mode = "fuzzy";
      secrets_filter = true;
    };
  };
}
