# All my terminal-specific user configuration.
args @ {
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  # extraSpecialArgs:
  system,
  username,
  pkgs-stable,
  pkgs-unstable,
  ...
}: {
  imports = [
    ../common.nix
    ./tmux.nix
    ./nushell.nix
    ./git.nix
    ./nixvim.nix
  ];

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # Fetchers
    neofetch
    hyfetch
    fastfetch

    tmatrix # Epic matrix effect
    du-dust # Disk usage visualizer (kind of like Filelight)

    sops # Secret management
    gh # GitHub CLI tool

    # Benchmarking
    geekbench
  ];

  # My system monitor of choice
  programs.btop.enable = true;

  # Another nice system monitor (command: btm)
  programs.bottom.enable = true;

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
      "--cmd cd" # Replace built-in cd command withzoxide
    ];
  };

  # File fuzzy finder
  programs.fzf.enable = true;

  # Quick, example-driven man pages powered by tldr-pages
  programs.tealdeer.enable = true;

  # Yazi is a TUI file manager
  programs.yazi = {
    enable = true;
    enableNushellIntegration = false; # Disable because we're waiting for nix-community/home-manager#5045
    package = pkgs-unstable.yazi;
  };

  # Atuin shell history
  programs.atuin = {
    enable = true;
    enableNushellIntegration = true;
    package = pkgs-unstable.atuin;
  };
}
