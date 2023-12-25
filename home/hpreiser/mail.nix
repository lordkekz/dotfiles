# Configure my email inboxes and calendars
args @ {
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  mode,
  system,
  ...
}: let
  mainProfile = "mainProfile";
in rec {
  accounts.email.accounts."privat" = rec {
    realName = "Heinrich Preiser";
    address = "heinrich.preiser@lkekz.de";
    aliases = ["lordkekz@lkekz.de"];
    primary = true;
    thunderbird.enable = true;
    thunderbird.profiles = [mainProfile];
    userName = address;
    imap = {
      host = "imap.goneo.de";
      port = 993;
      tls.enable = true;
    };
    smtp = {
      host = "smtp.goneo.de";
      port = 465;
      tls.enable = true;
    };
  };

  programs.thunderbird = {
    enable = true;
    package = pkgs.betterbird; # Betterbird has some extra features, like a tray icon.
    settings = {
      "privacy.donottrackheader.enabled" = true;
    };
    profiles.${mainProfile}.isDefault = true;
  };
}
