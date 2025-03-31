# Configure my email inboxes and calendars
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
}: let
  inherit (lib.attrsets) mapAttrs;

  mainProfile = "mainProfile";

  enableThunderbirdForMailbox = {
    thunderbird.enable = true;
    thunderbird.profiles = [mainProfile];
  };

  rawMailboxes = personal-data.data.home.mail;
  mailboxesWithThunderbird = mapAttrs (n: v: v // enableThunderbirdForMailbox) rawMailboxes;
in rec {
  accounts.email.accounts = mailboxesWithThunderbird;

  programs.thunderbird = {
    enable = true;
    package = pkgs.betterbird; # Betterbird has some extra features, like a tray icon.
    settings = {
      # Betterbird-specific options:
      "mail.minimizeToTray" = true;
      "mail.minimizeToTray.supportedDesktops" = "kde,gnome,xfce,mate, ,";
    };
    profiles.${mainProfile}.isDefault = true;
  };
}
