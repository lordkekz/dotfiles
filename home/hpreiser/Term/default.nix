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

    sops # Secret management
    gh # GitHub CLI tool
  ];

  programs.btop = {
    enable = true;
  };

  programs.bat = {
    enable = true;
    config.style = "full";
    extraPackages = with pkgs.bat-extras; [batman];
  };
}
