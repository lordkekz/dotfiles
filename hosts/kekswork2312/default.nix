# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  username = "hpreiser";
in {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.framework-12th-gen-intel

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix
    ../common/syncthing.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      #outputs.overlays.additions
      #outputs.overlays.modifications
      #outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };

    hostPlatform = "x86_64-linux";
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry =
    (lib.mapAttrs (_: flake: {inherit flake;}))
    ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs' (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Enable networking
  networking = {
    hostName = "kekswork2312";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
    };
    #wireless.enable = true; # Enables wireless support via wpa_supplicant.
  };

  # Enable Bluetooth
  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager = {
    defaultSession = "plasmawayland";
    sddm.enable = true;
    sddm.wayland.enable = false;
  };
  services.xserver.desktopManager.plasma5.enable = true;

  # Enable fingerprints
  services.fprintd.enable = true;
  # Disable fingerprint for lock screen auth, because passwords
  # are still required and it waits for fingerprint anyways if I entered the password.
  # FIXME find an alternative to SDDM which can handle multiple unlocking methods simultaneously.
  security.pam.services.kde.fprintAuth = false;
  security.pam.services.login.fprintAuth = false;

  # Fix missing maximize/minimize buttons on firefox etc.
  programs.dconf.enable = true; # doesn't help

  # Configure keymap in X11
  services.xserver = {
    layout = "de";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Basic user account config.
  users.users.${username} = {
    isNormalUser = true;
    description = "Heinrich Preiser";
    extraGroups = ["networkmanager" "wheel" "docker" "libvirtd"];
    packages = with pkgs; [
      firefox
      vscodium
    ];
  };

  environment.systemPackages = [
    # KDE Info Center dependencies
    pkgs.wayland-utils
    pkgs.clinfo
    pkgs.glxinfo
    pkgs.vulkan-tools-lunarg
    pkgs.pciutils # provides lspci
    pkgs.fwupd
  ];

  # Enable graphical KDE Partition Manager
  programs.partition-manager.enable = true;

  # Enable Steam
  programs.steam.enable = true;

  # Enable Flatpak with KDE
  services.flatpak.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-kde];
  xdg.portal.config.common.default = "kde";

  # Enable Waydroid to run Android apps on Linux.
  virtualisation.waydroid.enable = true;

  # Enable Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Enable virt-manager for QUEMU/KVM based VMs
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Globally enable git
  programs.git.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
