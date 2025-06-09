# A custom installer image based on the calamares plasma5 iso.
{
  inputs,
  outputs,
  hardwareProfiles,
  personal-data,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (personal-data.data.lab) username fullName hashedPassword publicKeys;
in {
  imports = [
    hardwareProfiles.common
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
  ];

  boot.kernelParams = ["copytoram"];

  environment.systemPackages = [
    # Cool stuff
    pkgs.fastfetch
    pkgs.nushell
    pkgs.bat
    pkgs.btop
    pkgs.ookla-speedtest
    pkgs.geekbench

    # KDE Info Center dependencies
    pkgs.wayland-utils
    pkgs.clinfo
    pkgs.glxinfo
    pkgs.vulkan-tools-lunarg
    pkgs.pciutils # provides lspci
    pkgs.usbutils # provides lsusb
    pkgs.fwupd
    pkgs.kdePackages.plasma-thunderbolt
  ];

  # Add my own user and set up public ssh keys
  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    description = fullName;
    inherit hashedPassword;
    openssh.authorizedKeys.keys = publicKeys;
    extraGroups = ["wheel" "systemd-journal"];
  };

  # Basic SSH hardening is good even on live image
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
