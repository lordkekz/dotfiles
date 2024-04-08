# A custom installer image based on the calamares plasma5 iso.
{
  inputs,
  outputs,
  hardwareProfiles,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    hardwareProfiles.common
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma5.nix"
  ];

  boot.kernelParams = ["copytoram"];

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
