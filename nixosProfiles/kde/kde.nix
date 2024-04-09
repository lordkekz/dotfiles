# Enable KDE Plasma 5
{
  inputs,
  outputs,
  nixosProfiles,
  lib,
  config,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  ...
}: {
  imports = [nixosProfiles.graphical];

  # Enable the KDE Plasma 5 Desktop Environment.
  services.xserver.displayManager = {
    defaultSession = "plasmawayland";
    sddm.enable = true;
    sddm.wayland.enable = false;
  };
  services.xserver.desktopManager.plasma5.enable = true;

  # Enable Flatpak with KDE
  services.flatpak.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-kde];
  xdg.portal.config.common.default = "kde";

  environment.systemPackages = [
    # KDE Info Center dependencies
    pkgs.plasma5Packages.plasma-thunderbolt
  ];

  # Disable fingerprint for lock screen auth, because passwords
  # are still required and it waits for fingerprint anyways if I entered the password.
  # FIXME find an alternative to SDDM which can handle multiple unlocking methods simultaneously.
  security.pam.services.kde.fprintAuth = false;
  security.pam.services.login.fprintAuth = false;
}
