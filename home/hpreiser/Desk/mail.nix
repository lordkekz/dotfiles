# Configure my email inboxes and calendars
args @ {
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  # extraSpecialArgs:
  system,
  username,
  personal-data,
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
    #package = pkgs.betterbird; # Betterbird has some extra features, like a tray icon.
    settings = {
      "privacy.donottrackheader.enabled" = true;
      # Betterbird-specific options:
      #"mail.minimizeToTray" = true;
      #"mail.minimizeToTray.supportedDesktops" = "kde,gnome,xfce,mate, ,";
    };
    profiles.${mainProfile}.isDefault = true;
  };
}
