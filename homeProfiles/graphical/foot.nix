# foot terminal
args @ {
  inputs,
  outputs,
  personal-data,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  system,
  lib,
  config,
  ...
}: {
  programs.foot = {
    enable = true;
    settings = {
      # TODO configure
    };
  };
}
