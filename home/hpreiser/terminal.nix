# All my terminal-specific user configuration.
args @ {
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  mode,
  ...
}: {
  programs.bat = {
    enable = true;
    config.style = "full";
    extraPackages = with pkgs.bat-extras; [batman];
  };
}
