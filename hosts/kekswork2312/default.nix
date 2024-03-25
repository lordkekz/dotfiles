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
    # You can also split up your configuration and import pieces of it here:
    # ./users.nix
    ../common/base-config.nix
    ../common/syncthing.nix
    ../common/firefox.nix
    ../common/tailscale.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware.nix
  ];

  # Bootloader.
  boot.loader = {
    # Use systemd-boot
    systemd-boot = {
      enable = true;
      # Maximum number of old NixOS generations to show in bootloader
      configurationLimit = 40;
      # Add an entry for Memtest86+ (the open source one)
      memtest86.enable = true;
    };
    efi.canTouchEfiVariables = true;

    # Default entry is booted after timeout seconds
    timeout = 1;
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

  # Enable Bolt deamon for thunderbolt
  services.hardware.bolt.enable = true;

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
    initialPassword = "changeme";
    extraGroups = ["networkmanager" "wheel" "docker" "libvirtd" "lxd"];
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
    pkgs.usbutils # provides lsusb
    pkgs.fwupd
    pkgs.plasma5Packages.plasma-thunderbolt
  ];

  environment.sessionVariables = {
    # Hint electron apps to use Wayland
    NIXOS_OZONE_WL = "1";
  };

  # Enable graphical KDE Partition Manager
  programs.partition-manager.enable = true;

  # Enable Steam
  programs.steam.enable = true;

  # Enable ratbagd, to configure peripherals with piper
  services.ratbagd.enable = true;

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

  # Enable LXC/LXD containers
  #virtualisation.lxd.enable = true;

  # Enable Incus LXC containers
  #virtualisation.incus.enable = true;

  # Enable virt-manager for QUEMU/KVM based VMs
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
