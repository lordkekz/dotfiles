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
  inherit (lib) optional optionals concatLists genList;
  inherit (builtins) toString;

  # The NixOS module applies some config to the package.
  # We just use that final package to avoid potential conflicts.
  hyprlandPackage =
    if args ? osConfig
    then args.osConfig.programs.hyprland.finalPackage
    else inputs.hyprland.packages.${system}.hyprland;

  vars = {
    mod1 = "SUPER";
    mod2 = "SUPER SHIFT";
    mod3 = "SUPER CONTROL";
    fileManager = "dolphin";
    menu = "walker";
  };

  # A list of bindings which only exist if alacritty is enabled.
  bindAlacritty = with config.programs.alacritty;
    optionals enable [
      "${vars.mod1}, T, exec, ${package}/bin/alacritty"
      "${vars.mod1}, Z, exec, ${package}/bin/alacritty -e nu"
    ];

  # FIXME use .desktop file
  bindFirefox = with config.programs.firefox;
    optional enable
    "${vars.mod1}, F, exec, ${package}/bin/firefox";

  # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
  bindWorkspaces = concatLists (genList (
      x: let
        ws = toString (x + 1);
      in [
        "${vars.mod2}, ${ws}, workspace, ${ws}"
        "${vars.mod3}, ${ws}, movetoworkspace, ${ws}"
      ]
    )
    10);

  # Plain, unconditional bindings
  bindGeneral = [
    ", Print, exec, grimblast copy area"
    "ALT, SPACE, exec, walker"
  ];

  bind = concatLists [bindAlacritty bindFirefox bindGeneral bindWorkspaces];
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprlandPackage;
    settings = {inherit bind;};
  };
}
