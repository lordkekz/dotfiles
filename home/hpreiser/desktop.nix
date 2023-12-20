# All my desktop-specific user configuration.
# TODO implement it properly
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
  imports = [./desktop-autostart.nix];

  # Make fonts from font packages available
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Nerfonts
    (pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})

    # Mixed apps
    obsidian # Markdown-based Notes
    vlc # Media player
    #birdtray # System tray icon for Thunderbird
    syncthingtray # FIXME it autostarts itself without nix's help. It also has a plasmoid.
    anki # Spaced-repetition flashcards
    filezilla # FTP client
    filelight # A fancy directory size viewer by KDE
    libreoffice
    jellyfin-media-player
    audacity
    kleopatra

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

    jetbrains-toolbox

    # VSCODIUM
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
  programs.thunderbird = {
    enable = true;
    package = pkgs.betterbird; # Betterbird has some extra features, like a tray icon.
    settings = {
      "privacy.donottrackheader.enabled" = true;
    };
    profiles = {};
  };

  # TODO use plasma-manager https://github.com/pjones/plasma-manager

  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {inherit (tpkgs) scheme-full;};
  };
  home.file.texmf.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/DocumentsSynced/texmf";

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  accounts.email.accounts."privat" = {
    thunderbird.enable = true;
    realName = "Heinrich Preiser";
    address = "heinrich.preiser@lkekz.de";
    primary = true;
  };
}
