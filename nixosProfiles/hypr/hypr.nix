# Enable Hyprland WM
{
  inputs,
  outputs,
  nixosProfiles,
  lib,
  config,
  system,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  ...
}: let
  greeting = "Resistance is futile.";
in {
  imports = [
    nixosProfiles.graphical
    inputs.hyprland.nixosModules.default
  ];

  services.tlp.enable = true;
  services.blueman.enable = true;
  services.udisks2.enable = true;

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${system}.hyprland;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    # Hint Electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config = {
      # Config for xdg-desktop-portal/portals.conf
      common = {
        preferred = "default=hyprland;gtk";
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet --cmd Hyprland --greeting "${greeting}" --time --asterisks --user-menu
        '';
        #command = ''
        #  ${pkgs.greetd.tuigreet}/bin/tuigreet --sessions "/etc/greetd/environments" --greeting "${greeting}" --time --asterisks --user-menu --theme border=black;text=gray;prompt=green;time=orange;action=cyan;button=green;container=lightgray;input=red
        #'';
        user = "greeter";
      };
    };
  };

  # Enable Hyprlock's pam module
  security.pam.services.hyprlock = {};

  # Unlock Kwallet when logging in with tuigreet
  security.pam.services.login.enableKwallet = true;
  security.pam.services.greetd.enableKwallet = true;

  # Enable polkit from KDE for sudo prompt popups
  security.polkit.enable = true;
  environment.systemPackages = [
    pkgs.libsForQt5.kwalletmanager

    # These packages contain systemd units, so they should autostart just by adding them here
    pkgs.libsForQt5.polkit-kde-agent
    pkgs.libsForQt5.kwallet-pam
    pkgs.libsForQt5.kwallet
  ];
}
