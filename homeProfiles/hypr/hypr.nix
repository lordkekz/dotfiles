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
  # The NixOS module applies some config to the package.
  # We just use that final package to avoid potential conflicts.
  hyprlandPackageMaybeFromOsConfig =
    if args ? osConfig
    then args.osConfig.programs.hyprland.finalPackage
    else inputs.hyprland.packages.${system}.hyprland;

  # A list of bindings which only exist if alacritty is enabled.
  alacrittyBinding =
    if config.programs.alacritty.enable
    then [
      "$mod, T, exec, ${config.programs.alacritty.package}/bin/alacritty"
      "$mod, A, exec, ${config.programs.alacritty.package}/bin/alacritty -e nu"
    ]
    else [];
in {
  imports = [
    homeProfiles.graphical
    inputs.hyprland.homeManagerModules.default
    inputs.hyprlock.homeManagerModules.default
    inputs.hypridle.homeManagerModules.default
    inputs.hyprpaper.homeManagerModules.default
  ];

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.package = hyprlandPackageMaybeFromOsConfig;
  services.dunst.enable = true;
  programs.hyprlock.enable = true;
  services.hypridle.enable = true;
  services.hyprpaper = rec {
    enable = true;
    preloads = [];
    wallpapers = [
      "eDP-1,/home/hpreiser/Downloads/chris-czermak-PamFFHL6fVY-unsplash.jpg"
      "DP-1,/home/hpreiser/Downloads/mike-yukhtenko-wfh8dDlNFOk-unsplash.jpg"
    ];
  };

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind =
      alacrittyBinding
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
