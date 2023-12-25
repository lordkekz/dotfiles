# All my desktop-specific user configuration.
args @ {
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  mode,
  system,
  ...
}: {
  # Make autostart symlinks
  imports = [
    ./desktop-autostart.nix
    ./mail.nix
    ./plasma-config.nix
  ];

  # Make fonts from font packages available
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Nerdfonts
    (nerdfonts.override {fonts = ["JetBrainsMono"];})

    # OFFICE
    obsidian # Markdown-based Notes
    libreoffice
    # FIXME choose which PDF tool to use
    pdfmixtool # https://www.scarpetta.eu/pdfmixtool
    pdfarranger # https://github.com/pdfarranger/pdfarranger
    diff-pdf # https://github.com/vslavik/diff-pdf

    # UTILITY
    syncthingtray # FIXME it autostarts itself without nix's help. It also has a plasmoid.
    anki # Spaced-repetition flashcards
    filezilla # FTP client
    filelight # A fancy directory size viewer by KDE
    meld # visual diff and merge tool
    kleopatra
    isoimagewriter # KDE's ISO Image Writer

    # MULTIMEDIA
    elisa
    vlc
    jellyfin-media-player
    audacity
    gimp
    (inkscape-with-extensions.override {inkscapeExtensions = with inkscape-extensions; [hexmap];})

    # GAMING AND WINE
    lutris # Open source gaming platform; use for GTA5
    minecraft
    optifine
    #steam # steam gets enabled in NixOSConfig
    wineWowPackages.stable # support both 32- and 64-bit applications
    linux-wallpaperengine # Wallpaper Engine

    # COMMUNICATION
    telegram-desktop
    signal-desktop
    discord
    # FIXME There is also 'element-desktop-wayland', maybe we need to use that for screen sharing or sth.
    element-desktop
    # There is an unofficial whatsapp client: whatsapp-for-linux

    # PROGRAMMING
    jetbrains-toolbox
    sqlitebrowser
    # vscodium
    (vscode-with-extensions.override
      {
        vscode = vscodium;
        vscodeExtensions = with inputs.nix-vscode-extensions.extensions.${system}.vscode-marketplace; [
          jnoortheen.nix-ide
          thenuprojectcontributors.vscode-nushell-lang
          ms-azuretools.vscode-docker
          tecosaur.latex-utilities
          james-yu.latex-workshop
        ];
      })
  ];

  programs.alacritty = import ./alacritty.nix {inherit pkgs;};

  programs.firefox.enable = true;

  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {inherit (tpkgs) scheme-full;};
  };
  home.file.texmf.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/DocumentsSynced/texmf";

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  # TODO test it
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-vkcapture
      obs-input-overlay
    ];
  };

  # Declaratively configure connection of virt-manager to libvirtd QEMU/KVM
  # https://nixos.wiki/wiki/Virt-manager
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
