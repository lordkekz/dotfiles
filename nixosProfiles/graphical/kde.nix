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
  # Enable the KDE Plasma 6 Desktop Environment.
  services.displayManager = {
    defaultSession = "plasma";
    sddm.enable = true;
    sddm.wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Enable Flatpak with KDE
  services.flatpak.enable = false;
  #xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-kde];
  #xdg.portal.config.common.default = "kde";

  environment.systemPackages = [
    # KDE Info Center dependencies
    pkgs.kdePackages.plasma-thunderbolt
    pkgs.dmidecode
  ];

  # Disable fingerprint for lock screen auth, because passwords
  # are still required and it waits for fingerprint anyways if I entered the password.
  # FIXME find an alternative to SDDM which can handle multiple unlocking methods simultaneously.
  security.pam.services.kde.fprintAuth = false;
  security.pam.services.login.fprintAuth = false;
}
