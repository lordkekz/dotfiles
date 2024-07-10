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
  imports = [inputs.hyprland.nixosModules.default];

  services.tlp = {
    enable = false;
    settings = {
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "passive";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 15;
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
    };
  };
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
    enable = false;
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

  # Use KDE's ksshaskpass instead of pkgs.x11_ssh_askpass
  programs.ssh.askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

  environment.systemPackages = [
    pkgs.kdePackages.kwalletmanager

    # These packages contain systemd units, so they should autostart just by adding them here
    pkgs.kdePackages.polkit-kde-agent-1
    pkgs.kdePackages.kwallet-pam
    pkgs.kdePackages.kwallet
  ];
}
