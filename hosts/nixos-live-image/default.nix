# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common/base-config.nix
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma5.nix"
  ];

  networking.hostName = "nixos-live";

  environment.systemPackages = with pkgs; [
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
    pkgs.plasma5Packages.plasma-thunderbolt
  ];

  # Enable SSH for headless access
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
  users.users.nixos.password = "5cLFL4D3r4F6"; # This is really, really not safe at all! But it's easy, so...

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
