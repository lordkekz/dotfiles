# All my desktop-specific user configuration.
# TODO implement it properly
args @ {
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  mode,
  ...
}:{
  programs.firefox.enable = true;
  home.packages = with pkgs; [
    dolphin
  ];
}
#throw "My desktop.nix is not yet implemented!"
