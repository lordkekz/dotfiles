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
}: {
  programs.firefox = {
    enable = true;
    profiles."default" = {
      id = 0;
      isDefault = true;
    };
    profiles."homework" = {
      id = 1;
      isDefault = false;
    };
  };
}
