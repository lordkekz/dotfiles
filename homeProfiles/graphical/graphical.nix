# All my desktop-specific user configuration.
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
}: {
  # Make autostart symlinks
  imports = [homeProfiles.terminal];

  # Make fonts from font packages available
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # OFFICE
    obsidian # Markdown-based Notes
    pkgs-unstable.zotero
    libreoffice
    pdfarranger # https://github.com/pdfarranger/pdfarranger
    diff-pdf # https://github.com/vslavik/diff-pdf
    kdePackages.okular # KDE pdf viewer

    # UTILITY
    tailscale-systray
    syncthingtray # It also has a plasmoid.
    anki-bin # Spaced-repetition flashcards
    kdePackages.dolphin # KDE file explorer
    kdePackages.ark # KDE file archiver
    filezilla # FTP client
    filelight # A fancy directory size viewer by KDE
    meld # visual diff and merge tool
    kleopatra
    isoimagewriter # KDE's ISO Image Writer
    piper # Frontend to configure peripherals using ratbagd
    gsmartcontrol # GUI for smartctl
    # ProtonVPN switched to a new GTK which isn't packaged in 23.11
    protonvpn-gui
    ookla-speedtest
    brightnessctl

    # MULTIMEDIA
    elisa
    vlc
    jellyfin-media-player
    audacity
    gimp
    (inkscape-with-extensions.override {inkscapeExtensions = with inkscape-extensions; [hexmap];})
    kdePackages.gwenview
    kdePackages.kdenlive # KDE video editor

    # GAMING AND WINE
    lutris # Open source gaming platform; use for GTA5
    prismlauncher
    #minecraft # official launcher is BROKEN, see https://github.com/NixOS/nixpkgs/issues/114732
    #optifine
    #steam # steam gets enabled in NixOSConfig
    wineWowPackages.stable # support both 32- and 64-bit applications
    #linux-wallpaperengine # Wallpaper Engine
    superTux
    superTuxKart
    extremetuxracer

    # COMMUNICATION
    birdtray
    telegram-desktop
    signal-desktop
    discord
    webcord
    # FIXME There is also 'element-desktop-wayland', maybe we need to use that for screen sharing or sth.
    element-desktop
    # There is an unofficial whatsapp client: whatsapp-for-linux

    # PROGRAMMING
    ollama
    jetbrains-toolbox
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    sqlitebrowser
    python312Full
    python312Packages.pip
    # vscodium
    (vscode-with-extensions.override
      {
        vscode = vscodium;
        vscodeExtensions = with inputs.nix-vscode-extensions.extensions.${system}.vscode-marketplace; [
          jnoortheen.nix-ide
          thenuprojectcontributors.vscode-nushell-lang
          ms-azuretools.vscode-docker
          #tecosaur.latex-utilities #their defaults are annoying
          james-yu.latex-workshop
          vscodevim.vim
        ];
      })
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # Used by Obsidian, as of 2024-01-01
  ];

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-vkcapture
      input-overlay
    ];
  };

  # Declaratively configure connection of virt-manager to libvirtd QEMU/KVM
  # https://wiki.nixos.org/wiki/Virt-manager
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
