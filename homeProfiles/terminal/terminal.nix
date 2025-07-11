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
  imports = [
    homeProfiles.common
    inputs.nix-index-database.hmModules.nix-index
  ];

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # Fetchers
    neofetch
    hyfetch
    fastfetch

    # Terminal flexing
    tmatrix
    pipes-rs
    cbonsai

    # Disk usage visualizers
    du-dust
    duf
    # Interactive explorer for nix derivations and dependencies
    nix-tree
    nix-output-monitor

    # Benchmarking
    phoronix-test-suite
    # disk benchmark
    fio
    # network benchmark
    iperf
    # Speedtest by Ookla
    ookla-speedtest
    # S.M.A.R.T. tools; provides smartctl
    smartmontools
    # Can do firmware updates for NVMe drives
    nvme-cli
    # Mobile shell that stays connected after sleep
    mosh

    # Misc
    tree
    inputs.devenv.packages.${system}.devenv
  ];

  programs.nh.enable = true; # Enable yet another nix helper

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

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

  # Direnv per-directory development environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };
  programs.nushell.environmentVariables.DIRENV_LOG_FORMAT = "";
}
