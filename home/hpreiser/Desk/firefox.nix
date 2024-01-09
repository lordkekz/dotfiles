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
    languagePacks = ["de" "en-US"];
    profiles."default".isDefault = true;
    profiles."homework".isDefault = false;
  };
}
