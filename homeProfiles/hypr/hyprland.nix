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
    anyrun = "${config.programs.anyrun.package}/bin/anyrun";
    anyrun-stdin = "${vars.anyrun} --plugins ${pkgs.anyrunPlugins.stdin}/lib/libstdin.so";
    cliphist = "${config.services.cliphist.package}/bin/cliphist";
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
    "${vars.mod1}, W, exec, ${package}/bin/firefox";

  # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
  bindWorkspaces = concatLists (genList (
      x: let
        key = toString x;
        ws =
          if x == 0
          then "10"
          else toString x;
      in [
        "${vars.mod1}, ${key}, workspace, ${ws}"
        "${vars.mod2}, ${key}, movetoworkspace, ${ws}"
      ]
    )
    10);

  bindWindowManagement = [
    # Move focus with SUPER + Arrow Keys
    "${vars.mod1}, left, movefocus, l"
    "${vars.mod1}, down, movefocus, d"
    "${vars.mod1}, up, movefocus, u"
    "${vars.mod1}, right, movefocus, r"
    # Switch window with SUPER + HJKL
    "${vars.mod1}, H, movewindow, l"
    "${vars.mod1}, J, movewindow, d"
    "${vars.mod1}, K, movewindow, u"
    "${vars.mod1}, L, movewindow, r"
    # Cycle Window with ALT [+ SHIFT] + TAB
    "ALT, TAB, cyclenext"
    "ALT SHIFT, TAB, cyclenext, prev"
    "${vars.mod1}, F, togglefloating"
    "ALT, F4, killactive"
  ];

  # Plain, unconditional bindings
  bindGeneral = [
    ", Print, exec, grimblast copy area"
    "ALT, SPACE, exec, ${vars.anyrun}"
    "${vars.mod1}, E, exec, ${vars.fileManager}"
    "${vars.mod1}, R, exec, ${pkgs.obsidian}/bin/obsidian"
    "${vars.mod1}, BACKSPACE, exit"
    "${vars.mod1}, V, exec, ${vars.cliphist} list | ${vars.anyrun-stdin} | ${vars.cliphist} decode | wl-copy"
  ];

  bind = concatLists [bindAlacritty bindFirefox bindWindowManagement bindGeneral bindWorkspaces];

  bindm = [
    "${vars.mod1}, mouse:272, movewindow"
    "${vars.mod1}, mouse:273, resizewindow"
  ];

  ####### MONITORS AND UTILITIES #######

  exec-once = [
    "${pkgs.libsForQt5.kwallet}/bin/kwalletd5 &"
    "sleep 3 && ${pkgs.libsForQt5.kwallet-pam}/libexec/pam_kwallet_init&"
  ];

  exec = [
    "pkill waybar; ${config.programs.waybar.package}/bin/waybar &"
    "[workspace 10 silent] sleep 0 && thunderbird"
    "[workspace 10 silent] sleep 1 && signal-desktop"
    "[workspace 10 silent] sleep 2 && discord"
    "[workspace 10 silent] pkill syncthingtray; sleep 3 && syncthingtray"
  ];

  monitor = [
    "eDP-1,preferred,0x0,1.6"
    "DP-1,preferred,1410x0,2,vrr,1,bitdepth,10"
    "DP-2,preferred,3330x0,1.6,vrr,1"
    #"eDP-1,disable"
    ",preferred,auto,auto,mirror,eDP-1"
  ];

  ####### LOOK AND FEEL #######

  # https://wiki.hyprland.org/Configuring/Variables/#general
  general = {
    gaps_in = 4;
    gaps_out = 4;
    border_size = 2;
    #"col.active_border" = "rgba(33ccffff) rgba(cc33ccee) rgba(ff9900ee) -50deg";
    #"col.inactive_border" = "rgba(595959aa)";
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
    #"col.shadow" = "rgba(1a1a1aee)";

    # https://wiki.hyprland.org/Configuring/Variables/#blur
    blur = {
      enabled = true;
      size = 5;
      passes = 3;

      popups = true;
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

  gestures = {
    workspace_swipe = true;
    workspace_swipe_fingers = 3;
    workspace_swipe_distance = 300;
    workspace_swipe_forever = true;
  };
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprlandPackage;
    settings = {
      inherit
        bind
        exec-once
        exec
        monitor
        general
        master
        decoration
        animations
        misc
        bindm
        input
        gestures
        ;
    };
  };
}
