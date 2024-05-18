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

  ####### KEY BINDINGS #######

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

  # Move focus with $mod1 + arrow keys
  bindWindowManagement = [
    "${vars.mod1}, left, movefocus, l"
    "${vars.mod1}, right, movefocus, r"
    "${vars.mod1}, up, movefocus, u"
    "${vars.mod1}, down, movefocus, d"
    "${vars.mod1}, V, togglefloating"
    "${vars.mod1}, X, killactive"
  ];

  # Plain, unconditional bindings
  bindGeneral = [
    ", Print, exec, grimblast copy area"
    "ALT, SPACE, exec, ${vars.menu}"
    "${vars.mod1}, E, exec, ${vars.fileManager}"
    "${vars.mod1}, BACKSPACE, exit"
  ];

  bind = concatLists [bindAlacritty bindFirefox bindWindowManagement bindGeneral bindWorkspaces];

  bindm = [
    "${vars.mod1}, mouse:272, movewindow"
    "${vars.mod1}, mouse:273, resizewindow"
  ];

  ####### MONITORS AND UTILITIES #######

  exec-once = [
    "${pkgs.hyprdim}/bin/hyprdim --no-dim-when-only --persist --ignore-leaving-special --dialog-dim"
    "${config.programs.waybar.package}/bin/waybar"
  ];

  monitor = [
    "DP-2,preferred,auto,2"
    "eDP-1,disable"
    ",preferred,auto,1"
  ];

  ####### LOOK AND FEEL #######

  # https://wiki.hyprland.org/Configuring/Variables/#general
  general = {
    gaps_in = 4;
    gaps_out = 10;
    border_size = 2;
    "col.active_border" = "rgba(33ccffff) rgba(cc33ccee) rgba(ff9900ee) -50deg";
    "col.inactive_border" = "rgba(595959aa)";
    resize_on_border = true;
    layout = "master";
  };

  master.orientation = "right";

  # https://wiki.hyprland.org/Configuring/Variables/#decoration
  decoration = {
    rounding = 10;

    # Change transparency of focused and unfocused windows
    active_opacity = 1.0;
    inactive_opacity = 0.9;

    drop_shadow = true;
    shadow_range = 4;
    shadow_render_power = 3;
    "col.shadow" = "rgba(1a1a1aee)";

    # https://wiki.hyprland.org/Configuring/Variables/#blur
    blur = {
      enabled = true;
      size = 3;
      passes = 1;

      vibrancy = 0.1696;
    };
  };

  # https://wiki.hyprland.org/Configuring/Variables/#animations
  animations = {
    enabled = true;

    # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

    bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

    animation = [
      "windows, 1, 7, myBezier"
      "windowsOut, 1, 7, default, popin 80%"
      "border, 1, 10, default"
      "borderangle, 1, 8, default"
      "fade, 1, 7, default"
      "workspaces, 1, 6, default"
    ];
  };

  # https://wiki.hyprland.org/Configuring/Variables/#misc
  misc = {
    force_default_wallpaper = 0;
    disable_hyprland_logo = false;
  };

  ####### INPUT METHODS #######
  # https://wiki.hyprland.org/Configuring/Variables/#input
  input = {
    kb_layout = "de";

    # Reset to usual behavior like KDE or Windows
    follow_mouse = 2;

    sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

    touchpad.natural_scroll = true;
  };
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprlandPackage;
    settings = {
      inherit
        bind
        exec-once
        monitor
        general
        master
        decoration
        animations
        misc
        bindm
        input
        ;
    };
  };
}
