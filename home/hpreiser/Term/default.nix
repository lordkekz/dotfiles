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
  ];

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [neofetch fastfetch sops];

  programs.btop = {
    enable = true;
  };

  programs.bat = {
    enable = true;
    config.style = "full";
    extraPackages = with pkgs.bat-extras; [batman];
  };
}
