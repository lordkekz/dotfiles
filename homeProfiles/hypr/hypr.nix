# My config for Hyprland window manager
args @ {
  inputs,
  outputs,
  homeProfiles,
  personal-data,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  system,
  lib,
  config,
  ...
}: let
  alacrittyPackage =
    if config.programs.alacritty.enable
    then config.programs.alacritty.package
    else null;
in {
  imports = [homeProfiles.graphical];

  wayland.windowManager.hyprland.enable = true;
  services.dunst.enable = true;

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind =
      (
        if alacrittyPackage != null
        then ["$mod, A, exec, ${alacrittyPackage}/bin/alacritty -e nu"]
        else []
      )
      ++ [
        "$mod, F, exec, firefox"
        ", Print, exec, grimblast copy area"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          )
          10)
      );
  };
}
