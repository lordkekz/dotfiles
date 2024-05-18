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

  security.polkit.enable = true;
  environment.systemPackages = [
    # Contains a systemd unit, so hopefully autostarts on its own
    pkgs.libsForQt5.polkit-kde-agent
  ];
}
