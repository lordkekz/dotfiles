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

  # A list of bindings which only exist if foot is enabled.
  bindFoot = with config.programs.foot;
    optionals enable [
      "${vars.mod1}, U, exec, ${package}/bin/foot"
      "${vars.mod1}, I, exec, ${package}/bin/foot -e nu"
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
        "${vars.mod3}, ${key}, focusworkspaceoncurrentmonitor, ${ws}"
      ]
    )
    10);

  bindWindowManagement = [
    # Change master layout's orientation using SUPER + SHIFT + Arrow Keys
    "${vars.mod2}, left,  layoutmsg, orientationleft"
    "${vars.mod2}, down,  layoutmsg, orientationbottom"
    "${vars.mod2}, up,    layoutmsg, orientationtop"
    "${vars.mod2}, right, layoutmsg, orientationright"
    "${vars.mod2}, SPACE, layoutmsg, orientationcenter"
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
    # Roll Window (master layout) with SUPER [+ SHIFT] + TAB
    "SUPER, TAB, layoutmsg, rollnext"
    "SUPER SHIFT, TAB, layoutmsg, rollprev"
    # Cycle Window with ALT [+ SHIFT] + TAB
    "ALT, TAB, cyclenext"
    "ALT SHIFT, TAB, cyclenext, prev"
    "ALT, F4, killactive"
    # Floating with SUPER + F
    "${vars.mod1}, F, togglefloating"
    "${vars.mod1}, F, resizeactive, exact 50% 50%"
    "${vars.mod1}, F, centerwindow, 1"
    # Maximize with SUPER + ENTER
    "${vars.mod1}, Return, fullscreen, 1"
    # Fullscreen with SUPER + F11
    "${vars.mod1}, F11, fullscreen, 0"
    # "Fake" Fullscreen with SUPER + SHIFT + F11
    # (doesn't tell the app that it's in fullscreen)
    "${vars.mod2}, F11, fullscreen, 2"
  ];

  # Plain, unconditional bindings
  bindGeneral = [
    #"${vars.mod2}, S, exec, ${pkgs.grimblast}/bin/grimblast copy area"
    "ALT, SPACE, exec, ${vars.anyrun}"
    "${vars.mod1}, E, exec, ${vars.fileManager}"
    "${vars.mod1}, R, exec, ${pkgs.obsidian}/bin/obsidian"
    "${vars.mod1}, BACKSPACE, exit"
    "${vars.mod1}, V, exec, ${vars.cliphist} list | ${vars.anyrun-stdin} | ${vars.cliphist} decode | wl-copy"
  ];

  bind = concatLists [bindAlacritty bindFoot bindFirefox bindWindowManagement bindGeneral bindWorkspaces];

  bindm = [
    "${vars.mod1}, mouse:272, movewindow"
    "${vars.mod1}, mouse:273, resizewindow"
  ];

  ####### MONITORS AND UTILITIES #######

  exec-once = [
    "${pkgs.kdePackages.kwallet}/bin/kwalletd5 &"
    "sleep 3 && ${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init &"
  ];

  silentStartIfNotRunning = ws: sleep: name: "[workspace ${toString ws} silent] pgrep ${name} || sleep ${toString sleep} && ${name}";

  exec = [
    "pkill waybar; waybar"
    "pkill syncthingtray; syncthingtray --wait"
    (silentStartIfNotRunning 10 0 "discord")
    (silentStartIfNotRunning 9 1 "thunderbird")
    (silentStartIfNotRunning 8 2 "signal-desktop")
  ];

  monitor = [
    "eDP-1, preferred, 0x0, 1.6"
    #"DP-1, preferred, 1410x0, 2, vrr, 1, bitdepth, 10"
    #"DP-2, preferred, 3330x0, 1.6, vrr, 1"
    #"eDP-1, disable"
    "desc:Philips Consumer Electronics Company 49M2C8900 AU42411000535,preferred,auto,1.25,vrr,0"
    ",preferred,auto,auto,mirror,eDP-1"
  ];

  xwayland.force_zero_scaling = true;
  env = [
    "GDK_SCALE,1.2"
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

  # Config for master layout on superwide monitor (three-column)
  master = {
    orientation = "center";
    always_center_master = true;
  };

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
        env
        exec
        monitor
        xwayland
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
