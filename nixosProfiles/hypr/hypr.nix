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
  greeting = "Resistance ist futile.";
in {
  imports = [
    nixosProfiles.graphical
    inputs.hyprland.nixosModules.default
  ];

  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages.${system}.hyprland;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet --sessions "/etc/greetd/environments" --greeting "${greeting}" --time --asterisks --user-menu
        '';
        #command = ''
        #  ${pkgs.greetd.tuigreet}/bin/tuigreet --sessions "/etc/greetd/environments" --greeting "${greeting}" --time --asterisks --user-menu --theme border=black;text=gray;prompt=green;time=orange;action=cyan;button=green;container=lightgray;input=red
        #'';
        user = "greeter";
      };
    };
  };

  environment.etc."greetd/environments".text = ''
    Hyprland
    tmux
    bash
  '';
}
